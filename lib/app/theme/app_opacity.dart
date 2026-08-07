/// Opacities that describe a *state* and repeat across unrelated components.
///
/// Deliberately two entries. An opacity that belongs to one widget is that
/// widget's business, and a token per literal (`o10`, `o20`, …) is a lookup
/// table pretending to be a scale.
abstract final class AppOpacity {
  /// A control that cannot be used right now.
  static const double disabled = 0.5;

  /// Content pushed behind something the user is interacting with.
  static const double dimmed = 0.2;
}
