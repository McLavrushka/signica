import 'package:flutter/material.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_typography.dart';

/// The design has a single (light) appearance, so the app ships one theme.
/// Component styling lives in the widgets themselves — the theme only carries
/// what Flutter needs globally.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF87E64C),
      surface: AppColors.surface,
    ),
    textTheme: TextTheme(
      titleLarge: AppTypography.appTitle,
      bodyMedium: AppTypography.documentName,
      bodySmall: AppTypography.documentDate,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
