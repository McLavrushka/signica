import 'package:flutter_test/flutter_test.dart';
import 'package:signica/features/documents/data/db/app_database.dart';
import 'package:signica/features/documents/data/mappers/document_mapper.dart';
import 'package:signica/features/documents/domain/entities/document.dart';

/// The mapper is the only place where a field can be dropped or crossed with
/// its neighbour without anything failing to compile — both sides are wide
/// records of mostly strings.
void main() {
  DocumentRow row({String? lastPreview, bool isSigned = false}) => DocumentRow(
    id: 'doc-1',
    name: 'Contract',
    filePath: 'documents/doc-1.pdf',
    firstPagePreviewPath: 'previews/doc-1-first.png',
    lastPagePreviewPath: lastPreview,
    pageCount: 3,
    createdAt: DateTime(2025, 4, 12, 9, 30),
    isSigned: isSigned,
  );

  test('every field survives row to entity', () {
    final Document entity = row(
      lastPreview: 'previews/doc-1-last.png',
    ).toEntity();

    expect(entity.id, 'doc-1');
    expect(entity.name, 'Contract');
    expect(entity.filePath, 'documents/doc-1.pdf');
    expect(entity.firstPagePreviewPath, 'previews/doc-1-first.png');
    expect(entity.lastPagePreviewPath, 'previews/doc-1-last.png');
    expect(entity.pageCount, 3);
    expect(entity.createdAt, DateTime(2025, 4, 12, 9, 30));
    expect(entity.isSigned, isFalse);
  });

  test('a round trip changes nothing', () {
    final DocumentRow original = row(
      lastPreview: 'previews/doc-1-last.png',
      isSigned: true,
    );

    expect(original.toEntity().toRow(), original);
  });

  /// A single-page document has no back page, and the grid decides how to draw
  /// the card from exactly that.
  test('a missing last preview stays missing', () {
    final Document entity = row().toEntity();

    expect(entity.lastPagePreviewPath, isNull);
    expect(entity.toRow().lastPagePreviewPath, isNull);
  });

  test('the signed flag is carried both ways', () {
    expect(row(isSigned: true).toEntity().isSigned, isTrue);
    expect(row().toEntity().isSigned, isFalse);
  });
}
