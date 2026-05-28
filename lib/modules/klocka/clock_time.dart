import 'package:flutter/foundation.dart';

/// A time of day in 24-hour form. The kid always answers in 24-hour digital
/// format (SPEC.md §6); the analog face shows the 12-hour position and a
/// sun/moon icon disambiguates AM vs PM.
@immutable
class ClockTime {
  const ClockTime(this.hour, this.minute)
      : assert(hour >= 0 && hour <= 23),
        assert(minute >= 0 && minute <= 59);

  final int hour; // 0–23
  final int minute; // 0–59

  /// Number shown on a 12-hour face (1–12; midnight/noon both read as 12).
  int get hour12 {
    final h = hour % 12;
    return h == 0 ? 12 : h;
  }

  /// True for AM (sun); false for PM (moon).
  bool get isMorning => hour < 12;

  /// 24-hour digital string, e.g. `15:30`.
  String get digital =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is ClockTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => 'ClockTime($digital)';
}
