import 'package:flutter/widgets.dart';
import 'package:signica/app/theme/app_colors.dart';

/// Text tokens from Figma. Inter and Sora ship as variable fonts, so every
/// style sets both [TextStyle.fontWeight] (for fallback and for the framework's
/// own bookkeeping) and the `wght` axis that actually moves the glyphs.
abstract final class AppTypography {
  /// "Signica" in the header — Inter 18 / 800, line height 21.6.
  static final TextStyle appTitle = _inter(18, 800, 21.6, AppColors.white);

  /// Segmented control labels — Inter 14 / 700, line height 18, ls -0.08.
  static final TextStyle segmentLabel = _inter(
    14,
    700,
    18,
    AppColors.textPrimary,
    letterSpacing: -0.08,
  );

  /// Document name under a preview — Inter 14 / 700, line height 16.8.
  static final TextStyle documentName = _inter(
    14,
    700,
    16.8,
    AppColors.textPrimary,
  );

  /// Document date — Inter 11 / 400, line height 13.2.
  static final TextStyle documentDate = _inter(
    11,
    400,
    13.2,
    AppColors.textSecondary,
  );

  /// Empty-state headline — Inter 20 / 700, line height 24.
  static final TextStyle emptyTitle = _inter(
    20,
    700,
    24,
    AppColors.textOnGlass,
  );

  /// Empty-state caption — Inter 15 / 400, line height 19.5.
  static final TextStyle emptySubtitle = _inter(
    15,
    400,
    19.5,
    AppColors.textOnGlass,
  ).copyWith(color: AppColors.textOnGlass.withValues(alpha: 0.4));

  /// Source pill and primary button label — Inter 16 / 700, line height 16.
  static final TextStyle sourceLabel = _inter(
    16,
    700,
    16,
    AppColors.textSourceLabel,
  );

  /// "Add Document" / "Add Document From" — Inter 16 / 700, line height 19.2.
  static final TextStyle actionLabel = _inter(
    16,
    700,
    19.2,
    AppColors.textOnGlass,
  );

  /// Context menu row — Inter 17 / 400, line height 20, ls -0.43.
  static final TextStyle menuItem = _inter(
    17,
    400,
    20,
    const Color(0xFF333333),
    letterSpacing: -0.43,
  );

  /// Search field input — Sora 17 / 600, line height 21.42.
  static final TextStyle searchField = _sora(
    17,
    600,
    21.42,
    AppColors.textPrimary,
  );

  /// "Signed" badge — Sora 14 / 600, line height 14.
  static final TextStyle signedBadge = _sora(14, 600, 14, AppColors.white);

  static TextStyle _inter(
    double size,
    int weight,
    double lineHeightPx,
    Color color, {
    double? letterSpacing,
  }) => _build('Inter', size, weight, lineHeightPx, color, letterSpacing);

  static TextStyle _sora(
    double size,
    int weight,
    double lineHeightPx,
    Color color, {
    double? letterSpacing,
  }) => _build('Sora', size, weight, lineHeightPx, color, letterSpacing);

  static TextStyle _build(
    String family,
    double size,
    int weight,
    double lineHeightPx,
    Color color,
    double? letterSpacing,
  ) => TextStyle(
    fontFamily: family,
    fontSize: size,
    // Figma reports line height in pixels; Flutter wants a multiplier.
    height: lineHeightPx / size,
    color: color,
    letterSpacing: letterSpacing,
    fontWeight: FontWeight.values[(weight ~/ 100) - 1],
    fontVariations: <FontVariation>[
      FontVariation('wght', weight.toDouble()),
    ],
  );
}
