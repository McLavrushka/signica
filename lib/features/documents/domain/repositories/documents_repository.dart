import 'package:signica/core/result.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/entities/documents_filter.dart';

/// Persistence boundary for documents. Implemented over drift.
abstract interface class DocumentsRepository {
  /// Live list, already filtered and sorted (newest first). Emits again on
  /// every write, so the UI never re-fetches by hand.
  ///
  /// A database error arrives as an `Err` in the stream rather than as an
  /// error event: the rule that no exception crosses a layer boundary has to
  /// hold for the source of truth too, not only for the one-shot calls.
  Stream<Result<List<Document>>> watch({
    String query = '',
    DocumentsFilter filter = DocumentsFilter.all,
  });

  /// Every stored name, used to resolve collisions before an import.
  Future<Result<List<String>>> allNames();

  Future<Result<Document>> add(Document document);

  Future<Result<void>> setSigned({required String id, required bool isSigned});

  /// Deletes the rows and the files they point at.
  Future<Result<void>> deleteMany(List<String> ids);
}
