import 'package:injectable/injectable.dart';
import 'package:signica/core/failure.dart';
import 'package:signica/core/result.dart';
import 'package:signica/core/use_case.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/entities/document_source.dart';
import 'package:signica/features/documents/domain/entities/picked_source.dart';
import 'package:signica/features/documents/domain/entities/stored_pdf.dart';
import 'package:signica/features/documents/domain/repositories/document_import_service.dart';
import 'package:signica/features/documents/domain/repositories/documents_repository.dart';
import 'package:signica/features/documents/domain/use_cases/resolve_document_name.dart';
import 'package:uuid/uuid.dart';

/// Parameters for [ImportDocument].
class ImportDocumentParams {
  const ImportDocumentParams({
    required this.source,
    required this.defaultName,
  });

  final DocumentSource source;

  /// Name used for scans and photos. Passed in from the presentation layer so
  /// the domain stays free of localisation.
  final String defaultName;
}

/// Pick → name → store → render previews → persist.
///
/// The whole add-document flow in one place; the bloc only decides *when* it
/// runs, never *how*.
@injectable
class ImportDocument implements UseCase<Result<Document>, ImportDocumentParams> {
  const ImportDocument(
    this._importService,
    this._repository,
    this._resolveName,
    this._uuid,
  );

  final DocumentImportService _importService;
  final DocumentsRepository _repository;
  final ResolveDocumentName _resolveName;
  final Uuid _uuid;

  @override
  Future<Result<Document>> call(ImportDocumentParams params) async {
    final Result<PickedSource> picked = await _importService.pick(
      params.source,
    );
    if (picked case Err<PickedSource>(:final Failure failure)) {
      return Err<Document>(failure);
    }
    final PickedSource source = (picked as Ok<PickedSource>).value;

    final String desiredName = switch (source) {
      PickedPdf(:final String originalName) => originalName,
      PickedImages() => params.defaultName,
    };

    final String name = _resolveName(
      ResolveDocumentNameParams(
        desiredName: desiredName,
        existingNames: await _repository.allNames(),
      ),
    );

    final String id = _uuid.v4();
    final Result<StoredPdf> stored = await _importService.store(
      picked: source,
      documentId: id,
    );
    if (stored case Err<StoredPdf>(:final Failure failure)) {
      return Err<Document>(failure);
    }
    final StoredPdf pdf = (stored as Ok<StoredPdf>).value;

    return _repository.add(
      Document(
        id: id,
        name: name,
        filePath: pdf.filePath,
        firstPagePreviewPath: pdf.firstPagePreviewPath,
        lastPagePreviewPath: pdf.lastPagePreviewPath,
        pageCount: pdf.pageCount,
        createdAt: DateTime.now(),
      ),
    );
  }
}
