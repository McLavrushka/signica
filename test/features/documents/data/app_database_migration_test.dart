import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signica/features/documents/data/db/app_database.dart';
import 'package:signica/features/documents/data/db/documents_dao.dart';

/// Migrations only ever run against databases that already exist on a user's
/// device, so nothing else in the suite exercises them: the DAO tests all start
/// from a fresh in-memory schema at the current version.
void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('signica_migration');
    file = File('${dir.path}/db.sqlite');
  });

  tearDown(() async {
    await dir.delete(recursive: true);
  });

  /// The v1 shape, written by hand — drift only generates the current schema.
  Future<void> seedV1(String name) async {
    final AppDatabase legacy = AppDatabase.forTesting(NativeDatabase(file));
    await legacy.customStatement('DROP TABLE IF EXISTS document_rows');
    await legacy.customStatement(
      'CREATE TABLE document_rows ('
      'id TEXT NOT NULL PRIMARY KEY, '
      'name TEXT NOT NULL, '
      'file_path TEXT NOT NULL, '
      'first_page_preview_path TEXT NOT NULL, '
      'last_page_preview_path TEXT, '
      'page_count INTEGER NOT NULL, '
      'created_at INTEGER NOT NULL, '
      'is_signed INTEGER NOT NULL DEFAULT 0)',
    );
    await legacy.customStatement(
      'INSERT INTO document_rows ('
      'id, name, file_path, first_page_preview_path, '
      'page_count, created_at, is_signed) '
      "VALUES ('1', ?, 'a.pdf', 'a.png', 1, 0, 0)",
      <Object>[name],
    );
    await legacy.customStatement('PRAGMA user_version = 1');
    await legacy.close();
  }

  test('v1 to v2 backfills the folded name of an existing document', () async {
    await seedV1('ДОГОВОР Аренды');

    final AppDatabase db = AppDatabase.forTesting(NativeDatabase(file));
    final List<DocumentRow> rows = await db.select(db.documentRows).get();

    // Folded in Dart, so the Cyrillic uppercase actually comes down.
    expect(rows.single.nameFolded, 'договор аренды');
    await db.close();
  });

  test(
    'a document imported before v2 is searchable after the upgrade',
    () async {
      await seedV1('Договор Аренды');

      final AppDatabase db = AppDatabase.forTesting(NativeDatabase(file));
      final List<DocumentRow> found = await DocumentsDao(
        db,
      ).watch(query: 'ДОГОВОР').first;

      expect(found.single.name, 'Договор Аренды');
      await db.close();
    },
  );
}
