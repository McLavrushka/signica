import 'package:injectable/injectable.dart';
import 'package:signica/core/result.dart';
import 'package:signica/core/use_case.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/repositories/document_exporter.dart';

/// Opens the system share sheet for the given documents.
@injectable
class ShareDocuments implements UseCase<Result<void>, List<Document>> {
  const ShareDocuments(this._exporter);

  final DocumentExporter _exporter;

  @override
  Future<Result<void>> call(List<Document> params) => _exporter.share(params);
}
