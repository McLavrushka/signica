import 'package:injectable/injectable.dart';
import 'package:signica/core/result.dart';
import 'package:signica/core/use_case.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/repositories/documents_repository.dart';

/// Flips a document between signed and unsigned.
///
/// The assignment simplifies real signing down to this toggle, so the use case
/// deliberately owns nothing but the state change.
@injectable
class ToggleSignature implements UseCase<Result<void>, Document> {
  const ToggleSignature(this._repository);

  final DocumentsRepository _repository;

  @override
  Future<Result<void>> call(Document params) =>
      _repository.setSigned(id: params.id, isSigned: !params.isSigned);
}
