import 'package:injectable/injectable.dart';
import 'package:signica/core/use_case.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/entities/documents_filter.dart';
import 'package:signica/features/documents/domain/repositories/documents_repository.dart';

/// Parameters for [WatchDocuments].
class WatchDocumentsParams {
  const WatchDocumentsParams({
    this.query = '',
    this.filter = DocumentsFilter.all,
  });

  final String query;
  final DocumentsFilter filter;
}

/// The grid's source of truth: a live, filtered list of documents.
@injectable
class WatchDocuments
    implements StreamUseCase<List<Document>, WatchDocumentsParams> {
  const WatchDocuments(this._repository);

  final DocumentsRepository _repository;

  @override
  Stream<List<Document>> call(WatchDocumentsParams params) =>
      _repository.watch(query: params.query, filter: params.filter);
}
