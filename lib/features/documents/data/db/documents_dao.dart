import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:signica/features/documents/data/db/app_database.dart';
import 'package:signica/features/documents/data/db/document_rows.dart';
import 'package:signica/features/documents/data/db/search_text.dart';
import 'package:signica/features/documents/domain/entities/documents_filter.dart';

part 'documents_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: <Type>[DocumentRows])
class DocumentsDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentsDaoMixin {
  DocumentsDao(super.db);

  /// Live query: drift re-emits on every write that touches the table, so
  /// filtering and searching happen in SQL rather than in the bloc.
  Stream<List<DocumentRow>> watch({
    String query = '',
    DocumentsFilter filter = DocumentsFilter.all,
  }) {
    final SimpleSelectStatement<$DocumentRowsTable, DocumentRow> statement =
        select(documentRows)
          ..orderBy(<OrderClauseGenerator<$DocumentRowsTable>>[
            ($DocumentRowsTable t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]);

    final String folded = foldSearchText(query);
    if (folded.isNotEmpty) {
      // `instr` over the folded column, not `LIKE`: it matches the needle
      // literally, so `%` and `_` typed by the user stay ordinary characters.
      statement.where(
        ($DocumentRowsTable t) => FunctionCallExpression<int>(
          'instr',
          <Expression<Object>>[t.nameFolded, Variable<String>(folded)],
        ).isBiggerThanValue(0),
      );
    }

    switch (filter) {
      case DocumentsFilter.all:
        break;
      case DocumentsFilter.signed:
        statement.where(($DocumentRowsTable t) => t.isSigned.equals(true));
      case DocumentsFilter.unsigned:
        statement.where(($DocumentRowsTable t) => t.isSigned.equals(false));
    }

    return statement.watch();
  }

  Future<List<String>> allNames() async {
    final List<DocumentRow> rows = await select(documentRows).get();
    return rows.map((DocumentRow row) => row.name).toList();
  }

  Future<List<DocumentRow>> byIds(List<String> ids) => (select(
    documentRows,
  )..where(($DocumentRowsTable t) => t.id.isIn(ids))).get();

  Future<void> insertRow(DocumentRow row) =>
      into(documentRows).insert(row, mode: InsertMode.insertOrReplace);

  Future<void> setSigned({required String id, required bool isSigned}) =>
      (update(documentRows)..where(($DocumentRowsTable t) => t.id.equals(id)))
          .write(DocumentRowsCompanion(isSigned: Value<bool>(isSigned)));

  Future<void> deleteByIds(List<String> ids) => (delete(
    documentRows,
  )..where(($DocumentRowsTable t) => t.id.isIn(ids))).go();
}
