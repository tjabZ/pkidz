import 'package:flutter/material.dart';

import '../../settings/settings.dart';
import '../../settings/settings_scope.dart';
import '../../shell/module_scaffold.dart';
import '../../theme/palette.dart';
import 'analog_clock.dart';
import 'clock_time.dart';
import 'klocka_settings_sheet.dart';
import 'settable_clock.dart';
import 'time_generator.dart';

/// Klocka: read the analog clock and answer in digital time, or (set-the-clock
/// direction) read a digital time and produce the clock (SPEC.md §6). Endless
/// practice — no score, no rounds.
class KlockaScreen extends StatefulWidget {
  const KlockaScreen({super.key});

  @override
  State<KlockaScreen> createState() => _KlockaScreenState();
}

class _KlockaScreenState extends State<KlockaScreen> {
  final _generator = TimeGenerator();

  int? _difficulty;
  KlockaAnswerMethod? _answerMethod;
  KlockaDirection? _direction;
  bool? _twelveHour;

  late ClockTime _target;

  // read-the-clock state
  late List<ClockTime> _choices;
  final _dimmed = <ClockTime>{};
  int _selectedHour = 12;
  int _selectedMinute = 0;

  // set-the-clock state
  late List<ClockTime> _faceChoices;
  final _dimmedFaces = <ClockTime>{};
  ClockTime _settable = const ClockTime(12, 0);

  bool _wrongFlash = false;
  bool _solved = false;

  /// 12-hour generation: the toggle, or always in the set-the-clock direction
  /// (a produced analog face can only express a 12-hour time).
  bool get _gen12 =>
      _direction == KlockaDirection.setClock || (_twelveHour ?? false);

  /// Higher difficulties drag the hands; lower pick from 4 faces.
  bool get _setDrag => (_difficulty ?? 1) >= 3;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = SettingsScope.of(context).settings;
    if (_difficulty == s.klockaDifficulty &&
        _answerMethod == s.klockaAnswerMethod &&
        _direction == s.klockaDirection &&
        _twelveHour == s.klocka12Hour) {
      return;
    }
    _difficulty = s.klockaDifficulty;
    _answerMethod = s.klockaAnswerMethod;
    _direction = s.klockaDirection;
    _twelveHour = s.klocka12Hour;
    _newQuestion();
  }

  void _newQuestion() {
    final difficulty = _difficulty ?? 1;
    setState(() {
      _target = _generator.next(difficulty, twelveHour: _gen12);
      _dimmed.clear();
      _dimmedFaces.clear();
      _wrongFlash = false;
      _solved = false;
      _selectedHour = 12;
      _selectedMinute = 0;
      _settable = const ClockTime(12, 0);
      if (_direction == KlockaDirection.readClock) {
        _choices = _generator.choices(_target, difficulty, twelveHour: _gen12);
      } else if (!_setDrag) {
        _faceChoices =
            _generator.choices(_target, difficulty, twelveHour: true);
      }
    });
  }

  void _markSolved() {
    setState(() => _solved = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _newQuestion();
    });
  }

  void _flashWrong() {
    setState(() => _wrongFlash = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _wrongFlash = false);
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

  void _onFaceTapped(ClockTime choice) {
    if (_solved) return;
    if (choice == _target) {
      _markSolved();
    } else {
      setState(() => _dimmedFaces.add(choice));
    }
  }

  void _submitScrolled() {
    if (_solved) return;
    if (ClockTime(_selectedHour, _selectedMinute) == _target) {
      _markSolved();
    } else {
      _flashWrong();
    }
  }

  void _submitSettable() {
    if (_solved) return;
    if (_settable == _target) {
      _markSolved();
    } else {
      _flashWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          final Widget question;
          final Widget answer;

          if (_direction == KlockaDirection.setClock) {
            question = _DigitalPrompt(time: _target);
            answer = _solved
                ? const _SolvedBanner()
                : _setDrag
                    ? _SettableArea(
                        value: _settable,
                        allowedMinutes:
                            TimeGenerator.minutesFor(_difficulty ?? 1),
                        wrong: _wrongFlash,
                        onChanged: (t) => setState(() => _settable = t),
                        onSubmit: _submitSettable,
                      )
                    : _FaceChoices(
                        choices: _faceChoices,
                        dimmed: _dimmedFaces,
                        onTap: _onFaceTapped,
                      );
          } else {
            question = _ClockArea(time: _target, showAmPm: !_gen12);
            answer = _solved
                ? const _SolvedBanner()
                : _answerMethod == KlockaAnswerMethod.multipleChoice
                    ? _MultipleChoice(
                        choices: _choices,
                        dimmed: _dimmed,
                        onTap: _onChoiceTapped,
                      )
                    : _Scrollers(
                        hour: _selectedHour,
                        minute: _selectedMinute,
                        minHour: _gen12 ? 1 : 0,
                        maxHour: _gen12 ? 12 : 23,
                        wrong: _wrongFlash,
                        onHour: (h) => _selectedHour = h,
                        onMinute: (m) => _selectedMinute = m,
                        onSubmit: _submitScrolled,
                      );
          }

          const padding = EdgeInsets.all(20);
          if (landscape) {
            return Padding(
              padding: padding,
              child: Row(
                children: [
                  Expanded(child: Center(child: question)),
                  const SizedBox(width: 20),
                  Expanded(child: Center(child: answer)),
                ],
              ),
            );
          }
          return Padding(
            padding: padding,
            child: Column(
              children: [
                Expanded(flex: 5, child: Center(child: question)),
                const SizedBox(height: 16),
                Expanded(flex: 4, child: Center(child: answer)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ClockArea extends StatelessWidget {
  const _ClockArea({required this.time, required this.showAmPm});

  final ClockTime time;
  final bool showAmPm;

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
              if (showAmPm)
                Icon(
                  time.isMorning
                      ? Icons.wb_sunny_rounded
                      : Icons.nightlight_round,
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

class _DigitalPrompt extends StatelessWidget {
  const _DigitalPrompt({required this.time});

  final ClockTime time;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Ställ klockan på:', style: TextStyle(fontSize: 22)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Palette.primary, width: 3),
          ),
          child: Text(
            time.digital,
            style: const TextStyle(
                fontSize: 56, fontWeight: FontWeight.w700, color: Palette.text),
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

class _FaceChoices extends StatelessWidget {
  const _FaceChoices({
    required this.choices,
    required this.dimmed,
    required this.onTap,
  });

  final List<ClockTime> choices;
  final Set<ClockTime> dimmed;
  final ValueChanged<ClockTime> onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final choice in choices)
              Opacity(
                opacity: dimmed.contains(choice) ? 0.3 : 1,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: dimmed.contains(choice) ? null : () => onTap(choice),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: AnalogClock(time: choice),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettableArea extends StatelessWidget {
  const _SettableArea({
    required this.value,
    required this.allowedMinutes,
    required this.wrong,
    required this.onChanged,
    required this.onSubmit,
  });

  final ClockTime value;
  final List<int> allowedMinutes;
  final bool wrong;
  final ValueChanged<ClockTime> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260, maxHeight: 260),
            child: SettableClock(
              value: value,
              allowedMinutes: allowedMinutes,
              onChanged: onChanged,
            ),
          ),
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

class _Scrollers extends StatelessWidget {
  const _Scrollers({
    required this.hour,
    required this.minute,
    required this.minHour,
    required this.maxHour,
    required this.wrong,
    required this.onHour,
    required this.onMinute,
    required this.onSubmit,
  });

  final int hour;
  final int minute;
  final int minHour;
  final int maxHour;
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
            _NumberWheel(
                min: minHour, max: maxHour, value: hour, onChanged: onHour),
            Text(':',
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: wrong ? Palette.wrong : Palette.text)),
            _NumberWheel(min: 0, max: 59, value: minute, onChanged: onMinute),
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
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
  });

  final int min;
  final int max; // inclusive upper bound
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 160,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: value - min),
        itemExtent: 56,
        physics: const FixedExtentScrollPhysics(),
        overAndUnderCenterOpacity: 0.4,
        onSelectedItemChanged: (index) => onChanged(index + min),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: max - min + 1,
          builder: (context, index) => Center(
            child: Text(
              (index + min).toString().padLeft(2, '0'),
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
