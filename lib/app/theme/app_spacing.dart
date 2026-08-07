/// Spacing scale of the app, in logical points.
///
/// Every gap that separates blocks comes from here, so the rhythm of the screen
/// is one decision instead of a number per place. Sizes that belong to a single
/// component (the height of a pill, the width of a menu) live next to that
/// component, not in this file.
abstract final class AppSpacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;
}
