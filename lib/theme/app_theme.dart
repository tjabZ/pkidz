import 'package:flutter/material.dart';

import 'palette.dart';

/// Builds the app-wide [ThemeData] from the Soft Scandinavian palette.
/// Rounded corners, generous spacing, large readable type (SPEC.md §4).
ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Palette.primary,
    brightness: Brightness.light,
    primary: Palette.primary,
    secondary: Palette.secondary,
    tertiary: Palette.accent,
    surface: Palette.background,
    onPrimary: Palette.text,
    onSecondary: Palette.text,
    onSurface: Palette.text,
  );

  const radius = BorderRadius.all(Radius.circular(24));

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Palette.background,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w700, color: Palette.text),
      headlineMedium:
          TextStyle(fontWeight: FontWeight.w700, color: Palette.text),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Palette.text),
      bodyLarge: TextStyle(fontSize: 20, color: Palette.text),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Palette.background,
      foregroundColor: Palette.text,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: radius),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Palette.primary,
        foregroundColor: Palette.text,
        shape: const RoundedRectangleBorder(borderRadius: radius),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
