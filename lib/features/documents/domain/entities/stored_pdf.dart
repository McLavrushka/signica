import 'package:equatable/equatable.dart';

/// A PDF that has been copied (or generated) into app storage and had its
/// preview pages rendered.
class StoredPdf extends Equatable {
  const StoredPdf({
    required this.filePath,
    required this.firstPagePreviewPath,
    required this.pageCount,
    this.lastPagePreviewPath,
  });

  final String filePath;
  final String firstPagePreviewPath;
  final String? lastPagePreviewPath;
  final int pageCount;

  @override
  List<Object?> get props => <Object?>[
    filePath,
    firstPagePreviewPath,
    lastPagePreviewPath,
    pageCount,
  ];
}
