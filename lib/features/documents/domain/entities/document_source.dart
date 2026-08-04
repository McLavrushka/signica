/// Where a new document comes from.
enum DocumentSource {
  /// System file picker, restricted to `.pdf`.
  files,

  /// Photo library, multi-select.
  photos,

  /// Camera-based document scanner.
  scanner,
}

extension DocumentSourceX on DocumentSource {
  /// Only files picked from Files keep their original name; everything else
  /// falls back to the default "New Document" name.
  bool get keepsOriginalName => this == DocumentSource.files;
}
