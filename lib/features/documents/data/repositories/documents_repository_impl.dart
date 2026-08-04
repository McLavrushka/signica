import 'package:injectable/injectable.dart';
import 'package:signica/core/failure.dart';
import 'package:signica/core/result.dart';
import 'package:signica/features/documents/data/db/app_database.dart';
import 'package:signica/features/documents/data/db/documents_dao.dart';
import 'package:signica/features/documents/data/mappers/document_mapper.dart';
import 'package:signica/features/documents/data/sources/file_storage.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/entities/documents_filter.dart';
import 'package:signica/features/documents/domain/repositories/documents_repository.dart';

@LazySingleton(as: DocumentsRepository)
class DocumentsRepositoryImpl implements DocumentsRepository {
  DocumentsRepositoryImpl(this._dao, this._storage);

  final DocumentsDao _dao;
  final FileStorage _storage;

  @override
  Stream<List<Document>> watch({
    String query = '',
    DocumentsFilter filter = DocumentsFilter.all,
  }) => _dao
      .watch(query: query, filter: filter)
      .map(
        (List<DocumentRow> rows) =>
            rows.map((DocumentRow row) => row.toEntity()).toList(),
      );

  @override
  Future<List<String>> allNames() => _dao.allNames();

  @override
  Future<Result<Document>> add(Document document) async {
    try {
      await _dao.insertRow(document.toRow());
      return Ok<Document>(document);
    } on Object catch (error) {
      return Err<Document>(DatabaseFailure(cause: error));
    }
  }

  @override
  Future<Result<void>> setSigned({
    required String id,
    required bool isSigned,
  }) async {
    try {
      await _dao.setSigned(id: id, isSigned: isSigned);
      return const Ok<void>(null);
    } on Object catch (error) {
      return Err<void>(DatabaseFailure(cause: error));
    }
  }

  @override
  Future<Result<void>> deleteMany(List<String> ids) async {
    try {
      final List<DocumentRow> rows = await _dao.byIds(ids);
      await _dao.deleteByIds(ids);

      // Files are removed after the rows: a failed delete must not leave the
      // grid pointing at a file that no longer exists.
      for (final DocumentRow row in rows) {
        await _storage.deleteIfExists(row.filePath);
        await _storage.deleteIfExists(row.firstPagePreviewPath);
        await _storage.deleteIfExists(row.lastPagePreviewPath);
      }
      return const Ok<void>(null);
    } on Object catch (error) {
      return Err<void>(StorageFailure(cause: error));
    }
  }
}
