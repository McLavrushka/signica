/// Where a new document comes from.
enum DocumentSource {
  /// System file picker, restricted to `.pdf`.
  files,

  /// Photo library, multi-select.
  photos,

  /// Camera-based document scanner.
  scanner,
}
