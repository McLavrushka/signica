import 'package:injectable/injectable.dart';
import 'package:signica/core/result.dart';
import 'package:signica/core/use_case.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/repositories/document_exporter.dart';

/// Opens the system print dialog for a document.
@injectable
class PrintDocument implements UseCase<Result<void>, Document> {
  const PrintDocument(this._exporter);

  final DocumentExporter _exporter;

  @override
  Future<Result<void>> call(Document params) => _exporter.print(params);
}
