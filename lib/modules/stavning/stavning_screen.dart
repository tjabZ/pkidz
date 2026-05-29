import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../content/content_models.dart';
import '../../content/content_scope.dart';
import '../../settings/settings.dart';
import '../../settings/settings_scope.dart';
import '../../shell/module_scaffold.dart';
import '../../theme/palette.dart';
import 'stavning_settings_sheet.dart';
import 'stavning_word.dart';
import 'word_generator.dart';

const Color _fadedText = Color(0x472F3E46); // deep slate ~28% — ghost hint
const Color _faintBorder = Color(0x402F3E46); // deep slate ~25% — blank box

/// Stavning: show an image, spell its Swedish word on the custom keyboard with
/// per-keystroke validation (SPEC.md §8). The kid types every letter at every
/// difficulty; difficulty only controls how many letters are shown faintly as
/// a tracing guide. Endless practice from the active category.
class StavningScreen extends StatefulWidget {
  const StavningScreen({super.key});

  @override
  State<StavningScreen> createState() => _StavningScreenState();
}

class _StavningScreenState extends State<StavningScreen> {
  final _generator = WordGenerator();

  String? _categoryName;
  StavningDifficulty? _difficulty;
  List<ContentItem> _items = const [];
  String _displayName = '';

  ContentItem? _item;
  StavningWord? _word;
  Set<int> _hints = const {};
  int _progress = 0; // letters correctly typed so far (== current cursor index)
  bool _solved = false;
  String? _flashKey;

  StavningDifficulty get _diff => _difficulty ?? StavningDifficulty.easy;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = SettingsScope.of(context).settings;
    final categoryChanged = settings.stavningCategory != _categoryName;
    final difficultyChanged = settings.stavningDifficulty != _difficulty;
    if (!categoryChanged && !difficultyChanged) return;

    _categoryName = settings.stavningCategory;
    _difficulty = settings.stavningDifficulty;
    if (categoryChanged) {
      final category = ContentScope.of(context).byName(_categoryName!);
      _items = category?.playableItems ?? const [];
      _displayName = category?.displayName ?? _categoryName!;
    }
    _newWord();
  }

  void _newWord() {
    final item = _generator.next(_items, avoid: _item);
    setState(() {
      _item = item;
      _word = item == null ? null : StavningWord(item.displayWord);
      _hints = _word?.hintIndices(_diff) ?? const {};
      _progress = 0;
      _solved = false;
      _flashKey = null;
    });
  }

  void _onKey(String key) {
    if (_solved || _word == null) return;
    if (_progress >= _word!.length) return;
    if (key == _word!.letters[_progress]) {
      setState(() => _progress++);
      if (_progress >= _word!.length) _markSolved();
    } else {
      HapticFeedback.lightImpact();
      setState(() => _flashKey = key);
      Future.delayed(const Duration(milliseconds: 320), () {
        if (mounted) setState(() => _flashKey = null);
      });
    }
  }

  void _onBackspace() {
    if (_solved || _progress == 0) return;
    setState(() => _progress--);
  }

  void _markSolved() {
    HapticFeedback.mediumImpact();
    setState(() => _solved = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _newWord();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uppercase = SettingsScope.of(context).settings.stavningUppercase;
    return ModuleScaffold(
      title: 'Stavning',
      actions: [
        IconButton(
          iconSize: 30,
          tooltip: 'Inställningar',
          icon: const Icon(Icons.settings_rounded),
          onPressed: () => showStavningSettings(context),
        ),
      ],
      child: _word == null
          ? _EmptyState(
              displayName: _displayName,
              onChangeCategory: () => showStavningSettings(context),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final landscape = constraints.maxWidth > constraints.maxHeight;
                final prompt = _Prompt(
                  item: _item!,
                  word: _word!,
                  hints: _hints,
                  progress: _progress,
                  solved: _solved,
                  uppercase: uppercase,
                );
                final keyboard = _Keyboard(
                  flashKey: _flashKey,
                  onKey: _onKey,
                  onBackspace: _onBackspace,
                  uppercase: uppercase,
                );
                const padding = EdgeInsets.all(16);
                if (landscape) {
                  return Padding(
                    padding: padding,
                    child: Row(
                      children: [
                        Expanded(child: Center(child: prompt)),
                        const SizedBox(width: 16),
                        Expanded(child: Center(child: keyboard)),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: padding,
                  child: Column(
                    children: [
                      Expanded(child: Center(child: prompt)),
                      const SizedBox(height: 12),
                      keyboard,
                    ],
                  ),
                );
              },
            ),
    );
  }
}

/// Image + the writing line of letter boxes.
class _Prompt extends StatelessWidget {
  const _Prompt({
    required this.item,
    required this.word,
    required this.hints,
    required this.progress,
    required this.solved,
    required this.uppercase,
  });

  final ContentItem item;
  final StavningWord word;
  final Set<int> hints;
  final int progress;
  final bool solved;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260, maxHeight: 260),
            child: Image.asset(item.imagePath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 20),
        _WritingLine(
          word: word,
          hints: hints,
          progress: progress,
          solved: solved,
          uppercase: uppercase,
        ),
      ],
    );
  }
}

class _WritingLine extends StatelessWidget {
  const _WritingLine({
    required this.word,
    required this.hints,
    required this.progress,
    required this.solved,
    required this.uppercase,
  });

  final StavningWord word;
  final Set<int> hints;
  final int progress;
  final bool solved;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < word.length; i++)
          _LetterCell(
            letter: uppercase
                ? word.letters[i].toUpperCase()
                : word.letters[i],
            typed: i < progress,
            hint: hints.contains(i),
            isCursor: i == progress && !solved,
            solved: solved,
          ),
      ],
    );
  }
}

class _LetterCell extends StatelessWidget {
  const _LetterCell({
    required this.letter,
    required this.typed,
    required this.hint,
    required this.isCursor,
    required this.solved,
  });

  final String letter;
  final bool typed;
  final bool hint;
  final bool isCursor;
  final bool solved;

  @override
  Widget build(BuildContext context) {
    final committed = typed || solved; // solid, dark letter
    final showLetter = committed || hint; // solid letter or faint ghost
    final Color border = solved
        ? Palette.correct
        : isCursor
            ? Palette.accent
            : (committed || hint)
                ? Palette.primary
                : _faintBorder;

    return Container(
      width: 44,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: solved
            ? Palette.correctBg
            : committed
                ? Colors.white
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: isCursor || solved ? 3 : 2),
      ),
      child: Text(
        showLetter ? letter : '',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: committed ? Palette.text : _fadedText,
        ),
      ),
    );
  }
}

/// Custom big-button Swedish keyboard — QWERTY layout, lowercase, with a
/// backspace key (SPEC.md §8). No Shift; matching is case-insensitive.
class _Keyboard extends StatelessWidget {
  const _Keyboard({
    required this.flashKey,
    required this.onKey,
    required this.onBackspace,
    required this.uppercase,
  });

  final String? flashKey;
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  final bool uppercase;

  static const _rows = ['qwertyuiopå', 'asdfghjklöä', 'zxcvbnm'];
  static const _keyW = 52.0;
  static const _keyH = 64.0;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    // Keys have a fixed natural size; one FittedBox scales the whole keyboard
    // down uniformly to the available width, so the 11-key top row never
    // overflows on narrow screens while columns stay aligned across rows.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < _rows.length; r++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: _gap / 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final ch in _rows[r].split(''))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: _gap / 2),
                      child: _Key(
                        width: _keyW,
                        height: _keyH,
                        flashing: flashKey == ch,
                        onTap: () => onKey(ch),
                        label: uppercase ? ch.toUpperCase() : ch,
                      ),
                    ),
                  if (r == _rows.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: _gap / 2),
                      child: _Key(
                        width: _keyW * 1.7,
                        height: _keyH,
                        flashing: false,
                        onTap: onBackspace,
                        icon: Icons.backspace_outlined,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.width,
    required this.height,
    required this.flashing,
    required this.onTap,
    this.label,
    this.icon,
  });

  final double width;
  final double height;
  final bool flashing;
  final VoidCallback onTap;
  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: flashing ? Palette.wrong : Colors.white,
        elevation: 1,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Center(
            child: icon != null
                ? Icon(icon, size: 24, color: Palette.text)
                : Text(
                    label!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Palette.text,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.displayName, required this.onChangeCategory});

  final String displayName;
  final VoidCallback onChangeCategory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.keyboard_outlined, size: 88, color: Palette.primary),
            const SizedBox(height: 20),
            Text(
              'Inga bilder i "$displayName" än',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, color: Palette.text),
            ),
            const SizedBox(height: 10),
            const Text(
              'Lägg till minst en bild i kategorins mapp för att stava.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Palette.text),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onChangeCategory,
              child: const Text('Byt kategori'),
            ),
          ],
        ),
      ),
    );
  }
}
