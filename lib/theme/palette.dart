import 'package:flutter/material.dart';

/// Soft Scandinavian palette — see SPEC.md §4.
/// Calm, warm, low-saturation colors with kid-sized contrast.
class Palette {
  Palette._();

  static const Color background = Color(0xFFF6F1E8); // warm cream
  static const Color primary = Color(0xFFA7C5BD); // sage
  static const Color secondary = Color(0xFF88A8C0); // muted blue
  static const Color accent = Color(0xFFE8B4A0); // peach
  static const Color text = Color(0xFF2F3E46); // deep slate
  static const Color correct = Color(0xFFB5D3A8); // right-answer border
  static const Color correctBg = Color(0xFFC8E0B5); // right-answer fill
  static const Color wrong = Color(0xFFE8A3A3); // wrong-answer feedback
}
