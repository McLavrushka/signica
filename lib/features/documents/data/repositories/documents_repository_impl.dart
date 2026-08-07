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

  /// `await for` and not `yield*`: only the loop puts the source stream's
  /// errors inside this `try`. `yield*` forwards them straight to the listener,
  /// past the catch — which is the whole thing this method exists to prevent.
  ///
  /// The stream ends after a failure rather than resuming. A drift query that
  /// has started throwing does not recover on its own, and a grid that silently
  /// went stale would be worse than one that reported the error once.
  @override
  Stream<Result<List<Document>>> watch({
    String query = '',
    DocumentsFilter filter = DocumentsFilter.all,
  }) async* {
    try {
      await for (final List<DocumentRow> rows in _dao.watch(
        query: query,
        filter: filter,
      )) {
        yield Ok<List<Document>>(rows.map(_toEntity).toList());
      }
    } on Object catch (error) {
      yield Err<List<Document>>(DatabaseFailure(cause: error));
    }
  }

  /// Rows keep paths relative to the app documents directory; entities carry
  /// absolute ones, rebuilt against the container the app is running in now.
  Document _toEntity(DocumentRow row) {
    final Document document = row.toEntity();
    return document.withResolvedPaths(
      filePath: _storage.absolute(document.filePath),
      firstPagePreviewPath: _storage.absolute(document.firstPagePreviewPath),
      lastPagePreviewPath: document.lastPagePreviewPath == null
          ? null
          : _storage.absolute(document.lastPagePreviewPath!),
    );
  }

  @override
  Future<Result<List<String>>> allNames() async {
    try {
      return Ok<List<String>>(await _dao.allNames());
    } on Object catch (error) {
      return Err<List<String>>(DatabaseFailure(cause: error));
    }
  }

  @override
  Future<Result<Document>> add(Document document) async {
    try {
      final Document stored = document.withResolvedPaths(
        filePath: _storage.relative(document.filePath),
        firstPagePreviewPath: _storage.relative(document.firstPagePreviewPath),
        lastPagePreviewPath: document.lastPagePreviewPath == null
            ? null
            : _storage.relative(document.lastPagePreviewPath!),
      );
      await _dao.insertRow(stored.toRow());
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

      // Rows go first so the grid stops pointing at these files before they
      // disappear. A file that then fails to delete is a leak, which is
      // recoverable; the reverse order would render a card with no page.
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
