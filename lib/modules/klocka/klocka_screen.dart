import 'package:flutter/material.dart';

import '../../settings/settings.dart';
import '../../settings/settings_scope.dart';
import '../../shell/module_scaffold.dart';
import '../../theme/palette.dart';
import 'analog_clock.dart';
import 'clock_time.dart';
import 'klocka_settings_sheet.dart';
import 'time_generator.dart';

/// Klocka: read the analog clock, answer in 24-hour time (SPEC.md §6).
/// Endless practice — no score, no rounds.
class KlockaScreen extends StatefulWidget {
  const KlockaScreen({super.key});

  @override
  State<KlockaScreen> createState() => _KlockaScreenState();
}

class _KlockaScreenState extends State<KlockaScreen> {
  final _generator = TimeGenerator();

  late ClockTime _target;
  late List<ClockTime> _choices;
  final _dimmed = <ClockTime>{};

  int _selectedHour = 12;
  int _selectedMinute = 0;
  bool _wrongFlash = false;
  bool _solved = false;

  int? _difficulty; // tracks the difficulty the current question was built for

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final difficulty = SettingsScope.of(context).settings.klockaDifficulty;
    if (_difficulty != difficulty) {
      _difficulty = difficulty;
      _newQuestion();
    }
  }

  void _newQuestion() {
    final difficulty = _difficulty ?? 1;
    setState(() {
      _target = _generator.next(difficulty);
      _choices = _generator.choices(_target, difficulty);
      _dimmed.clear();
      _selectedHour = 12;
      _selectedMinute = 0;
      _wrongFlash = false;
      _solved = false;
    });
  }

  void _markSolved() {
    setState(() => _solved = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _newQuestion();
    });
  }

  void _onChoiceTapped(ClockTime choice) {
    if (_solved) return;
    if (choice == _target) {
      _markSolved();
    } else {
      setState(() => _dimmed.add(choice));
    }
  }

  void _submitScrolled() {
    if (_solved) return;
    if (ClockTime(_selectedHour, _selectedMinute) == _target) {
      _markSolved();
    } else {
      setState(() => _wrongFlash = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _wrongFlash = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final method = SettingsScope.of(context).settings.klockaAnswerMethod;

    return ModuleScaffold(
      title: 'Klocka',
      actions: [
        IconButton(
          iconSize: 30,
          tooltip: 'Inställningar',
          icon: const Icon(Icons.settings_rounded),
          onPressed: () => showKlockaSettings(context),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final landscape = constraints.maxWidth > constraints.maxHeight;
          final clock = _ClockArea(time: _target);
          final input = _solved
              ? const _SolvedBanner()
              : method == KlockaAnswerMethod.multipleChoice
                  ? _MultipleChoice(
                      choices: _choices,
                      dimmed: _dimmed,
                      onTap: _onChoiceTapped,
                    )
                  : _Scrollers(
                      hour: _selectedHour,
                      minute: _selectedMinute,
                      wrong: _wrongFlash,
                      onHour: (h) => _selectedHour = h,
                      onMinute: (m) => _selectedMinute = m,
                      onSubmit: _submitScrolled,
                    );

          final padding = const EdgeInsets.all(20);
          if (landscape) {
            return Padding(
              padding: padding,
              child: Row(
                children: [
                  Expanded(child: Center(child: clock)),
                  const SizedBox(width: 20),
                  Expanded(child: Center(child: input)),
                ],
              ),
            );
          }
          return Padding(
            padding: padding,
            child: Column(
              children: [
                Expanded(flex: 5, child: Center(child: clock)),
                const SizedBox(height: 16),
                Expanded(flex: 4, child: Center(child: input)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ClockArea extends StatelessWidget {
  const _ClockArea({required this.time});

  final ClockTime time;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Vad är klockan?', style: TextStyle(fontSize: 22)),
        const SizedBox(height: 12),
        Flexible(
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280, maxHeight: 280),
                child: AnalogClock(time: time),
              ),
              Icon(
                time.isMorning ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                size: 40,
                color: time.isMorning ? Palette.accent : Palette.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MultipleChoice extends StatelessWidget {
  const _MultipleChoice({
    required this.choices,
    required this.dimmed,
    required this.onTap,
  });

  final List<ClockTime> choices;
  final Set<ClockTime> dimmed;
  final ValueChanged<ClockTime> onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 2.4,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final choice in choices)
            _ChoiceButton(
              time: choice,
              dimmed: dimmed.contains(choice),
              onTap: () => onTap(choice),
            ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.time,
    required this.dimmed,
    required this.onTap,
  });

  final ClockTime time;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.3 : 1,
      child: ElevatedButton(
        onPressed: dimmed ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: dimmed ? Palette.wrong : Palette.primary,
          disabledBackgroundColor: Palette.wrong,
        ),
        child: Text(time.digital, style: const TextStyle(fontSize: 30)),
      ),
    );
  }
}

class _Scrollers extends StatelessWidget {
  const _Scrollers({
    required this.hour,
    required this.minute,
    required this.wrong,
    required this.onHour,
    required this.onMinute,
    required this.onSubmit,
  });

  final int hour;
  final int minute;
  final bool wrong;
  final ValueChanged<int> onHour;
  final ValueChanged<int> onMinute;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _NumberWheel(max: 23, value: hour, onChanged: onHour),
            Text(':',
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: wrong ? Palette.wrong : Palette.text)),
            _NumberWheel(max: 59, value: minute, onChanged: onMinute),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: wrong ? Palette.wrong : Palette.accent,
          ),
          child: const Text('Svara'),
        ),
      ],
    );
  }
}

class _NumberWheel extends StatelessWidget {
  const _NumberWheel({
    required this.max,
    required this.value,
    required this.onChanged,
  });

  final int max; // inclusive upper bound (min is 0)
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 160,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: value),
        itemExtent: 56,
        physics: const FixedExtentScrollPhysics(),
        overAndUnderCenterOpacity: 0.4,
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: max + 1,
          builder: (context, index) => Center(
            child: Text(
              index.toString().padLeft(2, '0'),
              style: const TextStyle(
                  fontSize: 40, fontWeight: FontWeight.w600, color: Palette.text),
            ),
          ),
        ),
      ),
    );
  }
}

class _SolvedBanner extends StatelessWidget {
  const _SolvedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
      decoration: BoxDecoration(
        color: Palette.correctBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Palette.correct, width: 3),
      ),
      child: const Icon(Icons.check_rounded, size: 72, color: Palette.text),
    );
  }
}
