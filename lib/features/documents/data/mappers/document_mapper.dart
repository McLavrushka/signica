import 'package:signica/features/documents/data/db/app_database.dart';
import 'package:signica/features/documents/data/db/search_text.dart';
import 'package:signica/features/documents/domain/entities/document.dart';

/// Row ↔ entity translation. Keeps drift types out of the domain layer.
extension DocumentRowMapper on DocumentRow {
  Document toEntity() => Document(
    id: id,
    name: name,
    filePath: filePath,
    firstPagePreviewPath: firstPagePreviewPath,
    lastPagePreviewPath: lastPagePreviewPath,
    pageCount: pageCount,
    createdAt: createdAt,
    isSigned: isSigned,
  );
}

extension DocumentEntityMapper on Document {
  DocumentRow toRow() => DocumentRow(
    id: id,
    name: name,
    nameFolded: foldSearchText(name),
    filePath: filePath,
    firstPagePreviewPath: firstPagePreviewPath,
    lastPagePreviewPath: lastPagePreviewPath,
    pageCount: pageCount,
    createdAt: createdAt,
    isSigned: isSigned,
  );
}
