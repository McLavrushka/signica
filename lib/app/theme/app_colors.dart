import 'package:flutter/widgets.dart';

/// Colour tokens taken from the Figma file (`docs/figma-spec.md`).
/// Values are copied from the design, never eyeballed from a screenshot.
abstract final class AppColors {
  /// Dark header behind the logo and the "more" button.
  static const Color header = Color(0xFF242424);

  /// Rounded sheet that holds the whole content area.
  static const Color surface = Color(0xFFF0F0F0);

  static const Color white = Color(0xFFFFFFFF);

  /// Primary action gradient (Add Document button, logo tile).
  static const LinearGradient accent = LinearGradient(
    colors: <Color>[Color(0xFF87E64C), Color(0xFFA1FF67)],
  );

  /// "Signed" label gradient.
  static const LinearGradient signed = LinearGradient(
    colors: <Color>[Color(0xFF65E018), Color(0xFF6AD528)],
  );

  static const Color textPrimary = Color(0xFF191919);
  static const Color textSecondary = Color(0xFF929292);
  static const Color textOnGlass = Color(0xFF303030);
  static const Color textSourceLabel = Color(0xFF373737);
  static const Color glyph = Color(0xFF404040);

  /// Segmented control: track, separator and unselected label.
  static const Color segmentedTrack = Color(0x1F767680);
  static const Color segmentedSeparator = Color(0x4D8E8E93);

  /// Page sheet border and drop shadow in the document previews.
  static const Color sheetBorder = Color(0x96DADADA);
  static const Color sheetShadow = Color(0x14000000);

  static const Color divider = Color(0xFFE8E8E8);
  static const Color destructive = Color(0xFFFF383C);

  /// Placeholder text inside the search field.
  static const Color searchHint = Color(0xFFD9D9D9);
}
