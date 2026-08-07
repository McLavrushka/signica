import 'package:drift/drift.dart';

/// Stored documents. File paths are relative to the app documents directory,
/// which moves between installs and OS upgrades; the repository resolves them
/// through `FileStorage`. The files are removed together with the row.
class DocumentRows extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  /// Search index for [name], folded through `foldSearchText`. Derived, always
  /// written together with the name — never edited on its own. The empty
  /// default exists so `ALTER TABLE ... ADD COLUMN` can run on existing rows;
  /// the v2 migration backfills them right after.
  TextColumn get nameFolded => text().withDefault(const Constant(''))();

  TextColumn get filePath => text()();

  TextColumn get firstPagePreviewPath => text()();

  TextColumn get lastPagePreviewPath => text().nullable()();

  IntColumn get pageCount => integer()();

  DateTimeColumn get createdAt => dateTime()();

  BoolColumn get isSigned => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
