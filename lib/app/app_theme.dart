import 'package:flutter/material.dart';

import 'app_colours.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColours.teal,
      brightness: Brightness.light,
      primary: AppColours.teal,
      onPrimary: AppColours.deepNavy,
      secondary: AppColours.accentSoftTeal,
      surface: AppColours.lightWhite,
      onSurface: AppColours.deepNavy,
      surfaceContainerHighest: AppColours.lightOffWhite,
      outline: AppColours.accentCoolGrey,
      error: Colors.redAccent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColours.lightWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColours.deepNavy,
        foregroundColor: AppColours.lightWhite,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColours.teal,
        foregroundColor: AppColours.deepNavy,
      ),
    );
  }
}
