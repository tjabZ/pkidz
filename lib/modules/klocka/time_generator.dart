import 'dart:math';

import 'clock_time.dart';

/// Generates target times per difficulty band and builds plausible
/// multiple-choice option sets (SPEC.md §6).
class TimeGenerator {
  TimeGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Generated hours stay in a kid-relatable waking range (06:00–21:59),
  /// while still covering both AM (sun) and PM (moon).
  static const int minHour = 6;
  static const int maxHour = 21; // inclusive

  /// Allowed minute values for each difficulty band:
  /// 1 = full hours · 2 = +half · 3 = +quarter · 4 = every 5 minutes.
  static List<int> minutesFor(int difficulty) {
    switch (difficulty) {
      case 1:
        return const [0];
      case 2:
        return const [0, 30];
      case 3:
        return const [0, 15, 30, 45];
      case 4:
      default:
        return const [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];
    }
  }

  ClockTime next(int difficulty) {
    final hour = minHour + _random.nextInt(maxHour - minHour + 1);
    final minutes = minutesFor(difficulty);
    final minute = minutes[_random.nextInt(minutes.length)];
    return ClockTime(hour, minute);
  }

  /// [correct] plus distinct distractors from the same difficulty band,
  /// shuffled. Distractors are unique and never equal to [correct].
  List<ClockTime> choices(ClockTime correct, int difficulty,
      {int count = 4}) {
    final options = <ClockTime>{correct};
    var guard = 0;
    while (options.length < count && guard < 1000) {
      options.add(next(difficulty));
      guard++;
    }
    return options.toList()..shuffle(_random);
  }
}
