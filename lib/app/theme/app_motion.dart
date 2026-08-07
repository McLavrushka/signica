import 'package:flutter/animation.dart';

/// Motion tokens: how long things take and how they ease.
///
/// Keeping durations in one place is what makes transitions feel like one app
/// rather than a set of independently tuned widgets.
abstract final class AppMotion {
  /// Small state changes: a badge, an opacity swap.
  static const Duration fast = Duration(milliseconds: 180);

  /// Selection and control feedback.
  static const Duration medium = Duration(milliseconds: 240);

  /// Layout changes: the bottom bar morphing, the source overlay.
  static const Duration slow = Duration(milliseconds: 320);

  /// Default easing for layout changes.
  static const Curve standard = Curves.easeOutCubic;

  /// Slight overshoot for elements that appear.
  static const Curve emphasized = Curves.easeOutBack;

  /// Scale a surface grows from as it appears. One value: menus, overlays and
  /// the actions sheet are the same gesture and used to disagree.
  static const double appearScale = 0.9;
}
