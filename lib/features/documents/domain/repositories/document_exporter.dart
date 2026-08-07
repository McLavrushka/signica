import 'package:signica/core/result.dart';
import 'package:signica/features/documents/domain/entities/document.dart';

/// Sending a document out of the app: the share sheet and the print dialog.
///
/// Both are platform services, so the domain only states what it needs and the
/// data layer decides how it happens.
abstract interface class DocumentExporter {
  Future<Result<void>> share(List<Document> documents);

  Future<Result<void>> print(Document document);
}
