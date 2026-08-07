import 'package:equatable/equatable.dart';

/// A stored PDF document plus the pre-rendered previews shown in the grid.
///
/// Previews are rendered once, at import time, and kept on disk: the grid must
/// never re-rasterise a PDF page while scrolling.
class Document extends Equatable {
  const Document({
    required this.id,
    required this.name,
    required this.filePath,
    required this.firstPagePreviewPath,
    required this.pageCount,
    required this.createdAt,
    this.lastPagePreviewPath,
    this.isSigned = false,
  });

  final String id;

  /// Display name without the `.pdf` extension. Unique among stored documents.
  final String name;

  /// Absolute path of the PDF inside the app documents directory.
  final String filePath;

  /// Absolute path of the rendered first page (PNG).
  final String firstPagePreviewPath;

  /// Absolute path of the rendered last page (PNG). Null for single-page files.
  final String? lastPagePreviewPath;

  final int pageCount;
  final DateTime createdAt;
  final bool isSigned;

  /// Multi-page documents are drawn as a stack of two sheets in the grid.
  bool get hasBackPage => lastPagePreviewPath != null && pageCount > 1;

  /// Returns the same document with its file paths swapped.
  ///
  /// Used by the data layer, which stores paths relative to the app documents
  /// directory and resolves them when reading.
  Document withResolvedPaths({
    required String filePath,
    required String firstPagePreviewPath,
    String? lastPagePreviewPath,
  }) => Document(
    id: id,
    name: name,
    filePath: filePath,
    firstPagePreviewPath: firstPagePreviewPath,
    lastPagePreviewPath: lastPagePreviewPath,
    pageCount: pageCount,
    createdAt: createdAt,
    isSigned: isSigned,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    filePath,
    firstPagePreviewPath,
    lastPagePreviewPath,
    pageCount,
    createdAt,
    isSigned,
  ];
}
