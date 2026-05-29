import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'analog_clock.dart';
import 'clock_time.dart';

/// An interactive 12-hour clock the kid sets by dragging the hands (SPEC.md §6,
/// "set the clock" direction, higher difficulties). Touch near a hand to grab
/// it; the minute hand snaps to [allowedMinutes], the hour hand to whole hours.
class SettableClock extends StatefulWidget {
  const SettableClock({
    super.key,
    required this.value,
    required this.allowedMinutes,
    required this.onChanged,
  });

  final ClockTime value; // selected time (hour 1–12, minute already snapped)
  final List<int> allowedMinutes;
  final ValueChanged<ClockTime> onChanged;

  @override
  State<SettableClock> createState() => _SettableClockState();

  /// Hour (1–12) nearest to an angle in degrees clockwise from 12.
  static int hourFromAngle(double deg) {
    final h = (deg / 30).round() % 12;
    return h == 0 ? 12 : h;
  }

  /// The allowed minute value closest (on the circle) to [rawMinute] (0–59).
  static int snapMinute(int rawMinute, List<int> allowed) {
    var best = allowed.first;
    var bestDist = 60;
    for (final m in allowed) {
      final d = (rawMinute - m).abs();
      final circular = d > 30 ? 60 - d : d;
      if (circular < bestDist) {
        bestDist = circular;
        best = m;
      }
    }
    return best;
  }
}

enum _Hand { hour, minute }

class _SettableClockState extends State<SettableClock> {
  _Hand _active = _Hand.minute;

  static double _degFromCenter(Offset local, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final v = local - center;
    var deg = math.atan2(v.dx, -v.dy) * 180 / math.pi;
    if (deg < 0) deg += 360;
    return deg;
  }

  static double _angularDist(double a, double b) {
    final d = (a - b).abs() % 360;
    return d > 180 ? 360 - d : d;
  }

  void _onTouch(Offset local, Size size, {required bool grab}) {
    final deg = _degFromCenter(local, size);
    if (grab) {
      final toHour = _angularDist(deg, hourAngleDeg(widget.value));
      final toMinute = _angularDist(deg, minuteAngleDeg(widget.value));
      _active = toHour <= toMinute ? _Hand.hour : _Hand.minute;
    }
    if (_active == _Hand.hour) {
      widget.onChanged(
          ClockTime(SettableClock.hourFromAngle(deg), widget.value.minute));
    } else {
      final raw = (deg / 6).round() % 60;
      widget.onChanged(ClockTime(widget.value.hour,
          SettableClock.snapMinute(raw, widget.allowedMinutes)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (d) => _onTouch(d.localPosition, size, grab: true),
            onPanUpdate: (d) => _onTouch(d.localPosition, size, grab: false),
            child: CustomPaint(
              painter: ClockFacePainter(
                hourAngleDeg: hourAngleDeg(widget.value),
                minuteAngleDeg: minuteAngleDeg(widget.value),
              ),
            ),
          );
        },
      ),
    );
  }
}
