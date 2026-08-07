import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signica/features/documents/data/db/app_database.dart';
import 'package:signica/features/documents/data/db/documents_dao.dart';
import 'package:signica/features/documents/domain/entities/documents_filter.dart';

void main() {
  late AppDatabase db;
  late DocumentsDao dao;

  DocumentRow row(
    String id,
    String name, {
    bool isSigned = false,
    int daysAgo = 0,
  }) => DocumentRow(
    id: id,
    name: name,
    filePath: '/tmp/$id.pdf',
    firstPagePreviewPath: '/tmp/$id-first.png',
    pageCount: 1,
    createdAt: DateTime(2025, 4, 12).subtract(Duration(days: daysAgo)),
    isSigned: isSigned,
  );

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = DocumentsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('watch emits the newest document first', () async {
    await dao.insertRow(row('1', 'Older', daysAgo: 2));
    await dao.insertRow(row('2', 'Newer'));

    final List<DocumentRow> rows = await dao.watch().first;

    expect(rows.map((DocumentRow r) => r.name), <String>['Newer', 'Older']);
  });

  test('watch filters by signed state', () async {
    await dao.insertRow(row('1', 'Signed one', isSigned: true));
    await dao.insertRow(row('2', 'Unsigned one'));

    final List<DocumentRow> signed = await dao
        .watch(filter: DocumentsFilter.signed)
        .first;
    final List<DocumentRow> unsigned = await dao
        .watch(filter: DocumentsFilter.unsigned)
        .first;

    expect(signed.single.name, 'Signed one');
    expect(unsigned.single.name, 'Unsigned one');
  });

  test('watch matches the query case-insensitively', () async {
    await dao.insertRow(row('1', 'Rental Agreement'));
    await dao.insertRow(row('2', 'Resume'));

    final List<DocumentRow> rows = await dao.watch(query: 'rent').first;

    expect(rows.single.name, 'Rental Agreement');
  });

  test('watch re-emits after a write', () async {
    await dao.insertRow(row('1', 'Resume'));

    final Stream<List<DocumentRow>> stream = dao.watch();
    final Future<List<List<DocumentRow>>> collected = stream.take(2).toList();

    await dao.setSigned(id: '1', isSigned: true);

    final List<List<DocumentRow>> emissions = await collected;
    expect(emissions.first.single.isSigned, isFalse);
    expect(emissions.last.single.isSigned, isTrue);
  });

  test('allNames returns every stored name', () async {
    await dao.insertRow(row('1', 'Resume'));
    await dao.insertRow(row('2', 'Resume 2'));

    expect((await dao.allNames())..sort(), <String>['Resume', 'Resume 2']);
  });

  test('deleteByIds removes the rows', () async {
    await dao.insertRow(row('1', 'Resume'));
    await dao.insertRow(row('2', 'Contract'));

    await dao.deleteByIds(<String>['1']);

    final List<DocumentRow> rows = await dao.watch().first;
    expect(rows.single.name, 'Contract');
  });
}
