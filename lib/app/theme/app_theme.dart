import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_typography.dart';

/// The design has a single (light) appearance, so the app ships one theme.
/// Component styling lives in the widgets themselves — the theme only carries
/// what Flutter needs globally.
///
/// The theme is not decoration: the app mounts stock widgets it does not style
/// by hand — `CupertinoAlertDialog` for a failure, `CupertinoTextField` for
/// search — and they read the scale from here. Without the wiring below they
/// fall back to the framework's own face and grey.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accentStart,
      surface: AppColors.surface,
    ),
    // Material slots get the same scale, so any stock widget inherits it.
    // `apply` puts the design's ink on it: the styles themselves carry no
    // colour, and the framework default is `black87`, not our black.
    textTheme: _textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    // Only the colour is inherited: every glyph in the app is an `AppIcon`,
    // which reads this and is sized by its own call site, so a default size
    // here would be a number nothing asks for.
    iconTheme: const IconThemeData(color: AppColors.glyph),
    // Only `primaryColor`, and only because the alert dialog reads it for its
    // action. A `CupertinoTextThemeData` here would be dead: `CupertinoAlertDialog`
    // hard-codes `CupertinoSystemText` with `inherit: false`, so the app's scale
    // cannot reach it — and should not. A system alert that came up in the app's
    // own typeface would look wrong on iOS, not right.
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: AppColors.textPrimary,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );

  static TextTheme get _textTheme => TextTheme(
    titleLarge: AppTypography.titleL,
    titleMedium: AppTypography.titleM,
    titleSmall: AppTypography.titleS,
    bodyLarge: AppTypography.bodyL,
    bodyMedium: AppTypography.bodyM,
    bodySmall: AppTypography.bodyS,
    labelLarge: AppTypography.labelL,
    labelMedium: AppTypography.labelM,
    labelSmall: AppTypography.labelS,
  );
}
