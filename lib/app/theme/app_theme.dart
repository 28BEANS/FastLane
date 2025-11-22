import 'package:flutter/material.dart';

class AppTheme {
  // LIGHT THEME
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light, // REQUIRED
      ),
    );
  }

  // DARK THEME
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark, // REQUIRED
      ),
    );
  }
}
