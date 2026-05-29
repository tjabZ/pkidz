import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import 'clock_time.dart';

/// A custom-painted 12-hour analog clock face with hour + minute hands
/// (SPEC.md §6). Square; size it via its parent.
class AnalogClock extends StatelessWidget {
  const AnalogClock({super.key, required this.time});

  final ClockTime time;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: ClockFacePainter(
          hourAngleDeg: hourAngleDeg(time),
          minuteAngleDeg: minuteAngleDeg(time),
        ),
      ),
    );
  }
}

/// Hour-hand angle in degrees clockwise from 12, advancing within the hour.
double hourAngleDeg(ClockTime time) => (time.hour12 % 12 + time.minute / 60) * 30;

/// Minute-hand angle in degrees clockwise from 12.
double minuteAngleDeg(ClockTime time) => time.minute * 6.0;

/// Paints a 12-hour clock face with the hands at the given angles. Shared by
/// [AnalogClock] (read mode) and the draggable SettableClock (set mode).
class ClockFacePainter extends CustomPainter {
  ClockFacePainter({required this.hourAngleDeg, required this.minuteAngleDeg});

  final double hourAngleDeg;
  final double minuteAngleDeg;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final face = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final rim = Paint()
      ..color = Palette.text
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.04;
    canvas.drawCircle(center, radius - rim.strokeWidth / 2, face);
    canvas.drawCircle(center, radius - rim.strokeWidth / 2, rim);

    _drawTicksAndNumbers(canvas, center, radius);
    _drawHand(canvas, center, hourAngleDeg, radius * 0.52, radius * 0.045,
        Palette.text);
    _drawHand(canvas, center, minuteAngleDeg, radius * 0.78, radius * 0.03,
        Palette.secondary);

    canvas.drawCircle(center, radius * 0.05, Paint()..color = Palette.text);
  }

  void _drawTicksAndNumbers(Canvas canvas, Offset center, double radius) {
    final tick = Paint()
      ..color = Palette.text
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final angle = i * 30 * math.pi / 180;
      final outer = radius * 0.92;
      final inner = radius * 0.85;
      tick.strokeWidth = radius * 0.025;
      final dir = Offset(math.sin(angle), -math.cos(angle));
      canvas.drawLine(center + dir * inner, center + dir * outer, tick);

      final number = i == 0 ? 12 : i;
      final tp = TextPainter(
        text: TextSpan(
          text: '$number',
          style: TextStyle(
            color: Palette.text,
            fontSize: radius * 0.18,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final pos = center + dir * (radius * 0.7);
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawHand(Canvas canvas, Offset center, double degrees, double length,
      double width, Color color) {
    final angle = degrees * math.pi / 180;
    final dir = Offset(math.sin(angle), -math.cos(angle));
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, center + dir * length, paint);
  }

  @override
  bool shouldRepaint(ClockFacePainter old) =>
      old.hourAngleDeg != hourAngleDeg || old.minuteAngleDeg != minuteAngleDeg;
}
