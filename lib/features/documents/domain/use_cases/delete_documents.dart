import 'package:injectable/injectable.dart';
import 'package:signica/core/result.dart';
import 'package:signica/core/use_case.dart';
import 'package:signica/features/documents/domain/repositories/documents_repository.dart';

/// Deletes documents together with their files on disk.
@injectable
class DeleteDocuments implements UseCase<Result<void>, List<String>> {
  const DeleteDocuments(this._repository);

  final DocumentsRepository _repository;

  @override
  Future<Result<void>> call(List<String> params) =>
      _repository.deleteMany(params);
}
