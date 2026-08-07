import 'package:flutter/widgets.dart';

/// Shadows of the design, named after what floats — never after a blur value,
/// so a name stays true when the design tweaks the numbers.
///
/// A shadow is one decision made of three values that only mean something
/// together, which is why the token is the whole [BoxShadow] list and not a
/// colour in `AppColors` plus offsets spelled out at the call site.
abstract final class AppShadow {
  /// Page sheet of a document preview.
  static const List<BoxShadow> sheet = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 11.1),
  ];

  /// Context menu panel.
  static const List<BoxShadow> menu = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 5), blurRadius: 40),
  ];

  /// Thumb of the segmented control.
  static const List<BoxShadow> control = <BoxShadow>[
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 2), blurRadius: 20),
  ];

  /// Selection mark, which sits on a printed page and needs a much harder
  /// shadow than anything drawn on the app surface to stay visible.
  ///
  /// Exposed as a single [BoxShadow] as well, because the mark is painted by
  /// hand and needs the parts — `blurSigma` converts the radius for a
  /// [MaskFilter] so the two ways of drawing it cannot drift.
  static const BoxShadow markOnPage = BoxShadow(
    color: Color(0x99000000),
    offset: Offset(0, 1),
    blurRadius: 2,
  );

  static const List<BoxShadow> onPage = <BoxShadow>[markOnPage];
}
