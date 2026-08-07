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
  const ImportDocumentParams({required this.source, required this.defaultName});

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
class ImportDocument
    implements UseCase<Result<Document>, ImportDocumentParams> {
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
    // Each step unwraps by pattern rather than by cast: the switch is
    // exhaustive over the two cases of `Result`, so a missed branch is a
    // compile error instead of a run-time `as`.
    final PickedSource source;
    switch (await _importService.pick(params.source)) {
      case Err<PickedSource>(:final Failure failure):
        return Err<Document>(failure);
      case Ok<PickedSource>(:final PickedSource value):
        source = value;
    }

    final String desiredName = switch (source) {
      PickedPdf(:final String originalName) => originalName,
      PickedImages() => params.defaultName,
    };

    final List<String> existingNames;
    switch (await _repository.allNames()) {
      case Err<List<String>>(:final Failure failure):
        return Err<Document>(failure);
      case Ok<List<String>>(:final List<String> value):
        existingNames = value;
    }

    final String name = _resolveName(
      ResolveDocumentNameParams(
        desiredName: desiredName,
        existingNames: existingNames,
      ),
    );

    final String id = _uuid.v4();
    final StoredPdf pdf;
    switch (await _importService.store(picked: source, documentId: id)) {
      case Err<StoredPdf>(:final Failure failure):
        return Err<Document>(failure);
      case Ok<StoredPdf>(:final StoredPdf value):
        pdf = value;
    }

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
