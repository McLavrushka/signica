import 'dart:io' show FileSystemException;

import 'package:flutter/services.dart' show PlatformException;
import 'package:injectable/injectable.dart';
import 'package:signica/core/failure.dart';
import 'package:signica/core/result.dart';
import 'package:signica/features/documents/data/sources/document_picker.dart';
import 'package:signica/features/documents/data/sources/file_storage.dart';
import 'package:signica/features/documents/data/sources/pdf_processor.dart';
import 'package:signica/features/documents/domain/entities/document_source.dart';
import 'package:signica/features/documents/domain/entities/picked_source.dart';
import 'package:signica/features/documents/domain/entities/stored_pdf.dart';
import 'package:signica/features/documents/domain/repositories/document_import_service.dart';

@LazySingleton(as: DocumentImportService)
class DocumentImportServiceImpl implements DocumentImportService {
  DocumentImportServiceImpl(this._picker, this._processor, this._storage);

  final DocumentPicker _picker;
  final PdfProcessor _processor;
  final FileStorage _storage;

  @override
  Future<Result<PickedSource>> pick(DocumentSource source) async {
    try {
      final PickedSource? picked = switch (source) {
        DocumentSource.files => await _picker.pickPdf(),
        DocumentSource.photos => await _picker.pickPhotos(),
        DocumentSource.scanner => await _picker.scan(),
      };

      if (picked == null) {
        return const Err<PickedSource>(PickerCancelled());
      }
      return Ok<PickedSource>(picked);
    } on Object catch (error) {
      return Err<PickedSource>(_asFailure(error));
    }
  }

  @override
  Future<Result<StoredPdf>> store({
    required PickedSource picked,
    required String documentId,
  }) async {
    try {
      final String targetPath = _storage.pdfPath(documentId);

      switch (picked) {
        // Already a PDF: copy it in untouched, no re-encoding.
        case PickedPdf(:final String path):
          await _storage.copyTo(path, targetPath);
        // Images: one page per image, then treated exactly like a picked PDF.
        case PickedImages(:final List<String> paths):
          await _processor.buildPdfFromImages(
            imagePaths: paths,
            targetPath: targetPath,
          );
      }

      final RenderedPreviews previews = await _processor.renderPreviews(
        pdfPath: targetPath,
        documentId: documentId,
      );

      return Ok<StoredPdf>(
        StoredPdf(
          filePath: targetPath,
          firstPagePreviewPath: previews.firstPagePath,
          lastPagePreviewPath: previews.lastPagePath,
          pageCount: previews.pageCount,
        ),
      );
    } on Object catch (error) {
      // A half-written document must not survive a failed import.
      await _storage.deleteIfExists(_storage.pdfPath(documentId));
      return Err<StoredPdf>(_asFailure(error));
    }
  }

  /// Error codes the pickers raise when the OS refuses access. Codes are part
  /// of each plugin's documented contract; the messages behind them are
  /// localised by the system and must never be matched on.
  static const Set<String> _accessDeniedCodes = <String>{
    // image_picker, on both a denied photo library and a denied camera.
    'photo_access_denied',
    'camera_access_denied',
    // cunning_document_scanner, which needs the camera to scan.
    'PERMISSION_DENIED',
  };

  /// Classification by type, not by text.
  ///
  /// The previous version searched `error.toString()` for `'permission'`,
  /// `'pdf'` and `'render'`, which mislabels in both directions: a
  /// `PathNotFoundException` on `…/rendered.pdf` came out as [PdfFailure]
  /// because the path contains "pdf", and a localised OS message never
  /// contains "permission" at all.
  Failure _asFailure(Object error) => switch (error) {
    PdfRenderException() => PdfFailure(cause: error),
    FileSystemException() => StorageFailure(cause: error),
    PlatformException(:final String code)
        when _accessDeniedCodes.contains(code) =>
      PermissionDenied(cause: error),
    // Deliberately not StorageFailure: an unrecognised error is unknown, and
    // saying otherwise in the log helps nobody. The UI shows both the same.
    _ => UnexpectedFailure(cause: error),
  };
}
