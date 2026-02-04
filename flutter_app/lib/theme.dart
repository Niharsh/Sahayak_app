import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF00796B); // teal
  static const accent = Color(0xFFFF8A65); // orange
  static const background = Color(0xFFF6F7F9); // light grey
  static const danger = Color(0xFFD32F2F); // red
  static const pending = Color(0xFFFFEB3B); // yellow
  static const accepted = Color(0xFF1976D2); // blue
  static const inProgress = Color(0xFFFFA726); // orange
  static const completed = Color(0xFF43A047); // green
  static const cancelled = Color(0xFFD32F2F); // red
}

ThemeData buildAppTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white)),

    colorScheme: base.colorScheme.copyWith(secondary: AppColors.accent),
  );
}
