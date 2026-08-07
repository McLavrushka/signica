import 'package:flutter/widgets.dart';

/// Colour tokens of the design.
/// Values are copied from the design, never eyeballed from a screenshot.
abstract final class AppColors {
  /// Dark header behind the logo and the "more" button.
  static const Color header = Color(0xFF242424);

  /// Rounded sheet that holds the whole content area.
  static const Color surface = Color(0xFFF0F0F0);

  static const Color white = Color(0xFFFFFFFF);

  /// Brand green. Both stops live here because the gradient below and the
  /// `ColorScheme` seed in `AppTheme` have to move together.
  static const Color accentStart = Color(0xFF87E64C);
  static const Color accentEnd = Color(0xFFA1FF67);

  /// Primary action gradient (Add Document button, logo tile).
  static const LinearGradient accent = LinearGradient(
    colors: <Color>[accentStart, accentEnd],
  );

  /// Fill of a control on the dark header. Baked as a colour rather than
  /// applied with `withValues` at the call site: the transparency is part of
  /// the design, not a decision the widget makes, and this keeps it `const`.
  static const Color headerControl = Color(0x1AFFFFFF);

  /// Disc the signature mark of a signed document sits on.
  static const Color signedBadgeSurface = Color(0xFFFAFAFA);

  static const Color textPrimary = Color(0xFF191919);
  static const Color textSecondary = Color(0xFF929292);
  static const Color textOnGlass = Color(0xFF303030);

  /// Supporting line under a headline: [textOnGlass] at the 40% the design
  /// asks for, resolved once here instead of at the call site.
  static const Color textTertiary = Color(0x66303030);

  static const Color textSourceLabel = Color(0xFF373737);
  static const Color glyph = Color(0xFF404040);

  /// Segmented control: track, separator and unselected label.
  static const Color segmentedTrack = Color(0x1F767680);
  static const Color segmentedSeparator = Color(0x4D8E8E93);

  /// Label of a segment that is not the selected one: [textPrimary] at the 40%
  /// the design asks for. Baked as a colour for the same reason as
  /// [headerControl] — the transparency is the design's, not the widget's.
  static const Color textSegmentInactive = Color(0x66191919);

  /// Page sheet border in the document previews.
  static const Color sheetBorder = Color(0x96DADADA);

  /// Checkmark of a selected card.
  static const Color selection = Color(0xFF6AD528);

  /// Hairline between the blocks of a context menu.
  static const Color menuDivider = Color(0xFFE6E6E6);
  static const Color destructive = Color(0xFFFF383C);

  /// Glyphs and labels inside a context menu.
  static const Color menuForeground = Color(0xFF333333);

  /// Barrier behind a modal menu. The design puts nothing over the screen —
  /// it fades the cards around the menu — so the barrier only takes taps.
  static const Color barrier = Color(0x00000000);

  /// Placeholder text inside the search field.
  static const Color searchHint = Color(0xFFD9D9D9);
}
