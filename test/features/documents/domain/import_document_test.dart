import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:signica/core/failure.dart';
import 'package:signica/core/result.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/entities/document_source.dart';
import 'package:signica/features/documents/domain/entities/picked_source.dart';
import 'package:signica/features/documents/domain/entities/stored_pdf.dart';
import 'package:signica/features/documents/domain/repositories/document_import_service.dart';
import 'package:signica/features/documents/domain/repositories/documents_repository.dart';
import 'package:signica/features/documents/domain/use_cases/import_document.dart';
import 'package:signica/features/documents/domain/use_cases/resolve_document_name.dart';
import 'package:uuid/uuid.dart';

class _MockImportService extends Mock implements DocumentImportService {}

class _MockRepository extends Mock implements DocumentsRepository {}

class _MockUuid extends Mock implements Uuid {}

const String _id = 'generated-id';
const String _defaultName = 'New Document';

const PickedPdf _pickedPdf = PickedPdf(
  path: '/inbox/Contract.pdf',
  originalName: 'Contract',
);
const PickedImages _pickedImages = PickedImages(<String>['/inbox/page-1.jpg']);

const StoredPdf _stored = StoredPdf(
  filePath: '/docs/generated-id.pdf',
  firstPagePreviewPath: '/previews/generated-id-first.png',
  lastPagePreviewPath: '/previews/generated-id-last.png',
  pageCount: 2,
);

void main() {
  late _MockImportService importService;
  late _MockRepository repository;
  late _MockUuid uuid;
  late ImportDocument useCase;

  setUpAll(() {
    registerFallbackValue(DocumentSource.files);
    registerFallbackValue(_pickedPdf);
    registerFallbackValue(
      Document(
        id: _id,
        name: 'x',
        filePath: 'x',
        firstPagePreviewPath: 'x',
        pageCount: 1,
        createdAt: DateTime(2025),
      ),
    );
  });

  setUp(() {
    importService = _MockImportService();
    repository = _MockRepository();
    uuid = _MockUuid();
    useCase = ImportDocument(
      importService,
      repository,
      const ResolveDocumentName(),
      uuid,
    );

    when(() => uuid.v4()).thenReturn(_id);
    when(
      () => repository.allNames(),
    ).thenAnswer((_) async => const Ok<List<String>>(<String>[]));
    when(
      () => importService.store(
        picked: any(named: 'picked'),
        documentId: any(named: 'documentId'),
      ),
    ).thenAnswer((_) async => const Ok<StoredPdf>(_stored));
    when(() => repository.add(any())).thenAnswer(
      (Invocation i) async =>
          Ok<Document>(i.positionalArguments.first as Document),
    );
  });

  void givenPicked(PickedSource source) {
    when(
      () => importService.pick(any()),
    ).thenAnswer((_) async => Ok<PickedSource>(source));
  }

  Future<Result<Document>> run([
    DocumentSource source = DocumentSource.files,
  ]) =>
      useCase(ImportDocumentParams(source: source, defaultName: _defaultName));

  group('happy path', () {
    test('persists the document the storage layer actually produced', () async {
      givenPicked(_pickedPdf);

      final Result<Document> result = await run();

      final Document added =
          verify(() => repository.add(captureAny())).captured.single
              as Document;
      expect(added.id, _id);
      expect(added.filePath, _stored.filePath);
      expect(added.firstPagePreviewPath, _stored.firstPagePreviewPath);
      expect(added.lastPagePreviewPath, _stored.lastPagePreviewPath);
      expect(added.pageCount, _stored.pageCount);
      expect(result, isA<Ok<Document>>());
    });

    test('stores under the same id it generated', () async {
      givenPicked(_pickedPdf);

      await run();

      verify(
        () => importService.store(picked: _pickedPdf, documentId: _id),
      ).called(1);
    });
  });

  group('naming', () {
    test('a PDF from Files keeps the name it came with', () async {
      givenPicked(_pickedPdf);

      await run();

      final Document added =
          verify(() => repository.add(captureAny())).captured.single
              as Document;
      expect(added.name, 'Contract');
    });

    test('images have no name of their own and take the default', () async {
      givenPicked(_pickedImages);

      await run(DocumentSource.photos);

      final Document added =
          verify(() => repository.add(captureAny())).captured.single
              as Document;
      expect(added.name, _defaultName);
    });

    test('a taken name is resolved against the stored ones', () async {
      givenPicked(_pickedPdf);
      when(
        () => repository.allNames(),
      ).thenAnswer((_) async => const Ok<List<String>>(<String>['Contract']));

      await run();

      final Document added =
          verify(() => repository.add(captureAny())).captured.single
              as Document;
      expect(added.name, 'Contract 2');
    });
  });

  group('failures', () {
    test(
      'a cancelled picker stops the flow before anything is stored',
      () async {
        when(
          () => importService.pick(any()),
        ).thenAnswer((_) async => const Err<PickedSource>(PickerCancelled()));

        final Result<Document> result = await run();

        expect(result.failureOrNull, isA<PickerCancelled>());
        verifyNever(
          () => importService.store(
            picked: any(named: 'picked'),
            documentId: any(named: 'documentId'),
          ),
        );
        verifyNever(() => repository.add(any()));
      },
    );

    // The names lookup is the step that used to throw straight through the
    // domain; it now has to come back as a failure like every other step.
    test('a failed name lookup is returned, not thrown', () async {
      givenPicked(_pickedPdf);
      when(
        () => repository.allNames(),
      ).thenAnswer((_) async => const Err<List<String>>(DatabaseFailure()));

      final Result<Document> result = await run();

      expect(result.failureOrNull, isA<DatabaseFailure>());
      verifyNever(
        () => importService.store(
          picked: any(named: 'picked'),
          documentId: any(named: 'documentId'),
        ),
      );
    });

    test('nothing is persisted when storing fails', () async {
      givenPicked(_pickedPdf);
      when(
        () => importService.store(
          picked: any(named: 'picked'),
          documentId: any(named: 'documentId'),
        ),
      ).thenAnswer((_) async => const Err<StoredPdf>(PdfFailure()));

      final Result<Document> result = await run();

      expect(result.failureOrNull, isA<PdfFailure>());
      verifyNever(() => repository.add(any()));
    });

    test('a failed insert reaches the caller', () async {
      givenPicked(_pickedPdf);
      when(
        () => repository.add(any()),
      ).thenAnswer((_) async => const Err<Document>(DatabaseFailure()));

      final Result<Document> result = await run();

      expect(result.failureOrNull, isA<DatabaseFailure>());
    });
  });
}
