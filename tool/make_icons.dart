// Generates the p-KidZ app icon + splash logo with the Soft Scandinavian
// palette (SPEC.md §4). Pure Dart (package:image) — no ImageMagick needed.
// Run: dart run tool/make_icons.dart
import 'dart:io';

import 'package:image/image.dart';

final _sage = ColorRgb8(0xA7, 0xC5, 0xBD);
final _slate = ColorRgb8(0x2F, 0x3E, 0x46);
final _peach = ColorRgb8(0xE8, 0xB4, 0xA0);
final _white = ColorRgb8(255, 255, 255);

/// Draws a friendly clock (face + 10:10 hands + ticks) centred at [cx],[cy].
void _drawClock(Image img, int cx, int cy, int faceRadius) {
  final rim = (faceRadius * 0.07).round();
  fillCircle(img, x: cx, y: cy, radius: faceRadius, color: _slate, antialias: true);
  fillCircle(img, x: cx, y: cy, radius: faceRadius - rim, color: _white, antialias: true);

  // Four tick marks at 12 / 3 / 6 / 9.
  final tickR = (faceRadius * 0.82).round();
  final tick = (faceRadius * 0.04).round().clamp(4, 20);
  fillCircle(img, x: cx, y: cy - tickR, radius: tick, color: _slate, antialias: true);
  fillCircle(img, x: cx, y: cy + tickR, radius: tick, color: _slate, antialias: true);
  fillCircle(img, x: cx - tickR, y: cy, radius: tick, color: _slate, antialias: true);
  fillCircle(img, x: cx + tickR, y: cy, radius: tick, color: _slate, antialias: true);

  // Hands at ~10:10 (a calm, friendly pose).
  final hourLen = (faceRadius * 0.46).round();
  final minLen = (faceRadius * 0.70).round();
  drawLine(img,
      x1: cx,
      y1: cy,
      x2: cx - (hourLen * 0.62).round(),
      y2: cy - (hourLen * 0.78).round(),
      color: _slate,
      thickness: (faceRadius * 0.08).round().clamp(6, 30),
      antialias: true);
  drawLine(img,
      x1: cx,
      y1: cy,
      x2: cx + (minLen * 0.62).round(),
      y2: cy - (minLen * 0.78).round(),
      color: _peach,
      thickness: (faceRadius * 0.055).round().clamp(4, 22),
      antialias: true);

  fillCircle(img, x: cx, y: cy, radius: (faceRadius * 0.08).round(), color: _slate, antialias: true);
}

void main() {
  Directory('assets/icon').createSync(recursive: true);

  // App icon: full-bleed sage with the clock.
  final icon = Image(width: 1024, height: 1024, numChannels: 4);
  fill(icon, color: _sage);
  _drawClock(icon, 512, 512, 340);
  File('assets/icon/icon.png').writeAsBytesSync(encodePng(icon));

  // Splash logo: clock inside a sage disc on a transparent canvas (the splash
  // tool centres it on the cream background).
  final splash = Image(width: 1024, height: 1024, numChannels: 4);
  fillCircle(splash, x: 512, y: 512, radius: 470, color: _sage, antialias: true);
  _drawClock(splash, 512, 512, 300);
  File('assets/icon/splash.png').writeAsBytesSync(encodePng(splash));

  // ignore: avoid_print
  print('Wrote assets/icon/icon.png and assets/icon/splash.png');
}
