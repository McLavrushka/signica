import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:signica/core/failure.dart';
import 'package:signica/core/result.dart';
import 'package:signica/features/documents/data/repositories/document_import_service_impl.dart';
import 'package:signica/features/documents/data/sources/document_picker.dart';
import 'package:signica/features/documents/data/sources/file_storage.dart';
import 'package:signica/features/documents/data/sources/pdf_processor.dart';
import 'package:signica/features/documents/domain/entities/document_source.dart';
import 'package:signica/features/documents/domain/entities/picked_source.dart';
import 'package:signica/features/documents/domain/entities/stored_pdf.dart';

class _MockPicker extends Mock implements DocumentPicker {}

class _MockProcessor extends Mock implements PdfProcessor {}

class _MockStorage extends Mock implements FileStorage {}

const String _id = 'doc-1';
const String _target = '/base/documents/doc-1.pdf';
const PickedPdf _picked = PickedPdf(
  path: '/inbox/Report.pdf',
  originalName: 'Report',
);

void main() {
  late _MockPicker picker;
  late _MockProcessor processor;
  late _MockStorage storage;
  late DocumentImportServiceImpl service;

  setUp(() {
    picker = _MockPicker();
    processor = _MockProcessor();
    storage = _MockStorage();
    service = DocumentImportServiceImpl(picker, processor, storage);

    when(() => storage.pdfPath(_id)).thenReturn(_target);
    when(() => storage.deleteIfExists(any())).thenAnswer((_) async {});
  });

  /// Classification is the only place in the app that produces
  /// [PermissionDenied], and it used to depend on the wording of the error.
  /// Each case here pins it to something that is a contract instead: the
  /// exception type, or a documented plugin error code.
  group('failure classification', () {
    Future<Failure?> pickThrowing(Object error) async {
      when(() => picker.pickPdf()).thenThrow(error);
      final Result<PickedSource> result = await service.pick(
        DocumentSource.files,
      );
      return result.failureOrNull;
    }

    test('a denied photo library is a permission problem', () async {
      expect(
        await pickThrowing(PlatformException(code: 'photo_access_denied')),
        isA<PermissionDenied>(),
      );
    });

    test('a denied camera is a permission problem', () async {
      expect(
        await pickThrowing(PlatformException(code: 'camera_access_denied')),
        isA<PermissionDenied>(),
      );
    });

    test('the scanner reports its own denial code', () async {
      expect(
        await pickThrowing(PlatformException(code: 'PERMISSION_DENIED')),
        isA<PermissionDenied>(),
      );
    });

    test('an unrelated platform error is not a permission problem', () async {
      expect(
        await pickThrowing(PlatformException(code: 'multiple_request')),
        isA<UnexpectedFailure>(),
      );
    });

    test('a file system error is a storage problem', () async {
      expect(
        await pickThrowing(const FileSystemException('cannot read')),
        isA<StorageFailure>(),
      );
    });

    test('a render error is a PDF problem', () async {
      expect(
        await pickThrowing(const PdfRenderException('page 1 failed')),
        isA<PdfFailure>(),
      );
    });

    // The old string matching read the whole message, so a missing file whose
    // path merely contained "pdf" was reported as a broken document.
    test('a missing .pdf file is storage, not a broken document', () async {
      expect(
        await pickThrowing(
          const PathNotFoundException('/base/documents/doc-1.pdf', OSError()),
        ),
        isA<StorageFailure>(),
      );
    });

    // OS-facing text is localised, so it can never be the thing we match on.
    test('an unrecognised error stays unclassified', () async {
      expect(
        await pickThrowing(Exception('Zugriff verweigert')),
        isA<UnexpectedFailure>(),
      );
    });
  });

  group('pick', () {
    test('a dismissed picker is cancellation, not failure', () async {
      when(() => picker.pickPdf()).thenAnswer((_) async => null);

      final Result<PickedSource> result = await service.pick(
        DocumentSource.files,
      );

      expect(result.failureOrNull, isA<PickerCancelled>());
    });
  });

  group('store', () {
    setUp(() {
      when(
        () => storage.copyTo(any(), any()),
      ).thenAnswer((_) async => File(_target));
      when(
        () => processor.renderPreviews(
          pdfPath: any(named: 'pdfPath'),
          documentId: any(named: 'documentId'),
        ),
      ).thenAnswer(
        (_) async => const RenderedPreviews(
          firstPagePath: '/base/previews/doc-1-first.png',
          lastPagePath: '/base/previews/doc-1-last.png',
          pageCount: 3,
        ),
      );
    });

    test('a picked PDF is copied, never rebuilt', () async {
      final Result<StoredPdf> result = await service.store(
        picked: _picked,
        documentId: _id,
      );

      expect(result, isA<Ok<StoredPdf>>());
      verify(() => storage.copyTo(_picked.path, _target)).called(1);
      verifyNever(
        () => processor.buildPdfFromImages(
          imagePaths: any(named: 'imagePaths'),
          targetPath: any(named: 'targetPath'),
        ),
      );
    });

    // A document whose previews failed must not be left behind on disk, or the
    // next import inherits a half-written file under a fresh id's name.
    test('a half-written document is removed when rendering fails', () async {
      when(
        () => processor.renderPreviews(
          pdfPath: any(named: 'pdfPath'),
          documentId: any(named: 'documentId'),
        ),
      ).thenThrow(const PdfRenderException('page 1 failed'));

      final Result<StoredPdf> result = await service.store(
        picked: _picked,
        documentId: _id,
      );

      expect(result.failureOrNull, isA<PdfFailure>());
      verify(() => storage.deleteIfExists(_target)).called(1);
    });
  });
}
