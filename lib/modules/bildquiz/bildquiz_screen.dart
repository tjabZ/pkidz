import 'package:flutter/material.dart';

import '../../content/content_models.dart';
import '../../content/content_scope.dart';
import '../../settings/settings_scope.dart';
import '../../shell/module_scaffold.dart';
import '../../shell/pressable.dart';
import '../../theme/palette.dart';
import 'bildquiz_settings_sheet.dart';
import 'quiz_generator.dart';

/// Bildquiz: show a Swedish word, tap the matching image (SPEC.md §7).
/// Endless practice from the active category.
class BildquizScreen extends StatefulWidget {
  const BildquizScreen({super.key});

  @override
  State<BildquizScreen> createState() => _BildquizScreenState();
}

class _BildquizScreenState extends State<BildquizScreen> {
  final _generator = QuizGenerator();

  String? _categoryName;
  List<ContentItem> _items = const [];
  String _displayName = '';

  Question? _question;
  final _dimmed = <String>{};
  bool _solved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final name = SettingsScope.of(context).settings.bildquizCategory;
    if (name != _categoryName) {
      _categoryName = name;
      final category = ContentScope.of(context).byName(name);
      _items = category?.playableItems ?? const [];
      _displayName = category?.displayName ?? name;
      _newQuestion();
    }
  }

  void _newQuestion() {
    setState(() {
      _question = _generator.next(_items, avoidTarget: _question?.target);
      _dimmed.clear();
      _solved = false;
    });
  }

  void _onTap(ContentItem item) {
    if (_solved) return;
    if (item.key == _question!.target.key) {
      setState(() => _solved = true);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) _newQuestion();
      });
    } else {
      setState(() => _dimmed.add(item.key));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      title: 'Bildquiz',
      actions: [
        IconButton(
          iconSize: 30,
          tooltip: 'Inställningar',
          icon: const Icon(Icons.settings_rounded),
          onPressed: () => showBildquizSettings(context),
        ),
      ],
      child: _question == null
          ? _EmptyState(
              displayName: _displayName,
              onChangeCategory: () => showBildquizSettings(context),
            )
          : _Quiz(
              question: _question!,
              dimmed: _dimmed,
              solved: _solved,
              onTap: _onTap,
            ),
    );
  }
}

class _Quiz extends StatelessWidget {
  const _Quiz({
    required this.question,
    required this.dimmed,
    required this.solved,
    required this.onTap,
  });

  final Question question;
  final Set<String> dimmed;
  final bool solved;
  final ValueChanged<ContentItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            question.target.displayWord,
            style: const TextStyle(
                fontSize: 44, fontWeight: FontWeight.w700, color: Palette.text),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520, maxHeight: 520),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final item in question.options)
                      _QuizTile(
                        item: item,
                        dimmed: dimmed.contains(item.key),
                        correct: solved && item.key == question.target.key,
                        onTap: () => onTap(item),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizTile extends StatelessWidget {
  const _QuizTile({
    required this.item,
    required this.dimmed,
    required this.correct,
    required this.onTap,
  });

  final ContentItem item;
  final bool dimmed;
  final bool correct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.3 : 1,
      child: PressableScale(
        child: Card(
          color: correct ? Palette.correctBg : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: correct
                ? const BorderSide(color: Palette.correct, width: 4)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: dimmed ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(item.imagePath, fit: BoxFit.contain),
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
            const Icon(Icons.image_outlined, size: 88, color: Palette.primary),
            const SizedBox(height: 20),
            Text(
              'Inga bilder i "$displayName" än',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, color: Palette.text),
            ),
            const SizedBox(height: 10),
            const Text(
              'Lägg till minst 4 bilder i kategorins mapp för att spela.',
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
