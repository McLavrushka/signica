import 'package:drift/drift.dart';
import 'package:signica/features/documents/data/db/database_connection.dart';
import 'package:signica/features/documents/data/db/document_rows.dart';
import 'package:signica/features/documents/data/db/search_text.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: <Type>[DocumentRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabaseConnection());

  /// Test constructor: lets the DAO tests run against an in-memory database.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(documentRows, documentRows.nameFolded);
        await _backfillFoldedNames();
      }
    },
  );

  /// Folding runs in Dart, so existing rows cannot be backfilled with a plain
  /// `UPDATE ... lower(name)` — that would reintroduce the ASCII-only bug for
  /// every document imported before this migration.
  Future<void> _backfillFoldedNames() async {
    final List<DocumentRow> rows = await select(documentRows).get();
    await batch((Batch batch) {
      for (final DocumentRow row in rows) {
        batch.update(
          documentRows,
          DocumentRowsCompanion(
            nameFolded: Value<String>(foldSearchText(row.name)),
          ),
          where: ($DocumentRowsTable t) => t.id.equals(row.id),
        );
      }
    });
  }
}
