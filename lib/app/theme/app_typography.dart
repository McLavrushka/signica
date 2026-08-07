import 'package:flutter/widgets.dart';

/// Type scale of the app.
///
/// Styles carry typography only. Colour is applied where the text is used, the
/// way Material's own `TextTheme` works, so one style serves both the white
/// label on the header and the dark one on a card.
///
/// The same scale is wired into `ThemeData.textTheme` in `AppTheme`, so stock
/// widgets inherit it instead of falling back to the framework default.
abstract final class AppTypography {
  // Titles.

  /// Headline of a full-screen message.
  static final TextStyle titleL = _inter(size: 20, weight: FontWeight.w700);

  /// Product name.
  static final TextStyle titleM = _inter(size: 18, weight: FontWeight.w800);

  /// Name of an item in a list or a grid.
  static final TextStyle titleS = _inter(size: 14, weight: FontWeight.w700);

  // Body.

  /// Rows of a context menu. The tracking is what iOS applies at this size.
  static final TextStyle bodyL = _inter(
    size: 17,
    weight: FontWeight.w400,
    tracking: -0.43,
  );

  /// Supporting paragraph under a headline.
  static final TextStyle bodyM = _inter(
    size: 15,
    weight: FontWeight.w400,
    height: 1.3,
  );

  /// Metadata under an item: dates, counts.
  static final TextStyle bodyS = _inter(size: 11, weight: FontWeight.w400);

  // Labels of controls.

  /// Primary button.
  static final TextStyle labelL = _inter(size: 16, weight: FontWeight.w700);

  /// Secondary control: a segmented control, a compact action.
  static final TextStyle labelM = _inter(
    size: 14,
    weight: FontWeight.w700,
    height: 1.3,
  );

  /// Caption under an icon, where the line box has to breathe.
  static final TextStyle labelS = _inter(
    size: 12,
    weight: FontWeight.w600,
    height: 1.5,
  );

  /// Text the user types. Sora is the accent face of the design.
  static final TextStyle inputL = _font(
    'Sora',
    size: 17,
    weight: FontWeight.w600,
    height: 1.25,
  );

  /// Line box of most of the scale, in multiples of the font size.
  static const double _defaultHeight = 1.2;

  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    double height = _defaultHeight,
    double? tracking,
  }) => _font(
    'Inter',
    size: size,
    weight: weight,
    height: height,
    tracking: tracking,
  );

  /// Both families ship as variable fonts, so the weight is set twice: on the
  /// `wght` axis, which is what actually moves the glyphs, and as a
  /// [FontWeight], which the framework uses to pick and to fall back.
  ///
  /// Leading is split evenly above and below the line, so a single line sits in
  /// the middle of a fixed-height control instead of low in it.
  static TextStyle _font(
    String family, {
    required double size,
    required FontWeight weight,
    required double height,
    double? tracking,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    height: height,
    letterSpacing: tracking,
    fontWeight: weight,
    fontVariations: <FontVariation>[
      FontVariation('wght', weight.value.toDouble()),
    ],
    leadingDistribution: TextLeadingDistribution.even,
  );
}
