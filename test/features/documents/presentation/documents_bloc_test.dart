import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:signica/core/failure.dart';
import 'package:signica/core/result.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/entities/document_source.dart';
import 'package:signica/features/documents/domain/entities/documents_filter.dart';
import 'package:signica/features/documents/domain/use_cases/delete_documents.dart';
import 'package:signica/features/documents/domain/use_cases/import_document.dart';
import 'package:signica/features/documents/domain/use_cases/toggle_signature.dart';
import 'package:signica/features/documents/domain/use_cases/watch_documents.dart';
import 'package:signica/features/documents/presentation/bloc/documents_bloc.dart';

class _MockWatchDocuments extends Mock implements WatchDocuments {}

class _MockImportDocument extends Mock implements ImportDocument {}

class _MockToggleSignature extends Mock implements ToggleSignature {}

class _MockDeleteDocuments extends Mock implements DeleteDocuments {}

final Document _document = Document(
  id: '1',
  name: 'Resume',
  filePath: '/tmp/1.pdf',
  firstPagePreviewPath: '/tmp/1-first.png',
  pageCount: 1,
  createdAt: DateTime(2025, 4, 12),
);

void main() {
  late _MockWatchDocuments watchDocuments;
  late _MockImportDocument importDocument;
  late _MockToggleSignature toggleSignature;
  late _MockDeleteDocuments deleteDocuments;

  setUpAll(() {
    registerFallbackValue(const WatchDocumentsParams());
    registerFallbackValue(
      const ImportDocumentParams(
        source: DocumentSource.files,
        defaultName: 'New Document',
      ),
    );
    registerFallbackValue(_document);
  });

  setUp(() {
    watchDocuments = _MockWatchDocuments();
    importDocument = _MockImportDocument();
    toggleSignature = _MockToggleSignature();
    deleteDocuments = _MockDeleteDocuments();

    when(() => watchDocuments(any())).thenAnswer(
      (_) => Stream<List<Document>>.value(<Document>[_document]),
    );
  });

  DocumentsBloc build() => DocumentsBloc(
    watchDocuments,
    importDocument,
    toggleSignature,
    deleteDocuments,
  );

  group('subscription', () {
    blocTest<DocumentsBloc, DocumentsState>(
      'emits loading then the list from the repository stream',
      build: build,
      act: (DocumentsBloc bloc) => bloc.add(const DocumentsSubscribed()),
      expect: () => <Matcher>[
        isA<DocumentsState>().having(
          (DocumentsState s) => s.status,
          'status',
          DocumentsStatus.loading,
        ),
        isA<DocumentsState>()
            .having(
              (DocumentsState s) => s.status,
              'status',
              DocumentsStatus.ready,
            )
            .having(
              (DocumentsState s) => s.documents,
              'documents',
              <Document>[_document],
            ),
      ],
    );
  });

  group('search', () {
    blocTest<DocumentsBloc, DocumentsState>(
      'debounces keystrokes and queries only the last one',
      build: build,
      act: (DocumentsBloc bloc) async {
        bloc
          ..add(const DocumentsQueryChanged('r'))
          ..add(const DocumentsQueryChanged('re'))
          ..add(const DocumentsQueryChanged('res'));
      },
      wait: const Duration(milliseconds: 400),
      verify: (_) {
        final List<WatchDocumentsParams> calls =
            verify(() => watchDocuments(captureAny())).captured
                .cast<WatchDocumentsParams>();
        expect(calls.single.query, 'res');
      },
    );

    blocTest<DocumentsBloc, DocumentsState>(
      'ignores a query that did not change',
      build: build,
      seed: () => const DocumentsState(query: 'res'),
      act: (DocumentsBloc bloc) => bloc.add(const DocumentsQueryChanged('res')),
      wait: const Duration(milliseconds: 400),
      expect: () => <DocumentsState>[],
    );
  });

  group('filter', () {
    blocTest<DocumentsBloc, DocumentsState>(
      'stores the filter and re-subscribes with it',
      build: build,
      act: (DocumentsBloc bloc) =>
          bloc.add(const DocumentsFilterChanged(DocumentsFilter.signed)),
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        final List<WatchDocumentsParams> calls =
            verify(() => watchDocuments(captureAny())).captured
                .cast<WatchDocumentsParams>();
        expect(calls.last.filter, DocumentsFilter.signed);
      },
    );
  });

  group('import', () {
    blocTest<DocumentsBloc, DocumentsState>(
      'flags the import while it runs and clears it afterwards',
      build: build,
      setUp: () {
        when(() => importDocument(any())).thenAnswer(
          (_) async => Ok<Document>(_document),
        );
      },
      act: (DocumentsBloc bloc) => bloc.add(
        const DocumentImportRequested(
          source: DocumentSource.photos,
          defaultName: 'New Document',
        ),
      ),
      expect: () => <Matcher>[
        isA<DocumentsState>().having(
          (DocumentsState s) => s.isImporting,
          'isImporting',
          isTrue,
        ),
        isA<DocumentsState>()
            .having((DocumentsState s) => s.isImporting, 'isImporting', isFalse)
            .having((DocumentsState s) => s.failure, 'failure', isNull),
      ],
    );

    blocTest<DocumentsBloc, DocumentsState>(
      'treats a cancelled picker as a non-error',
      build: build,
      setUp: () {
        when(() => importDocument(any())).thenAnswer(
          (_) async => const Err<Document>(PickerCancelled()),
        );
      },
      act: (DocumentsBloc bloc) => bloc.add(
        const DocumentImportRequested(
          source: DocumentSource.files,
          defaultName: 'New Document',
        ),
      ),
      expect: () => <Matcher>[
        isA<DocumentsState>().having(
          (DocumentsState s) => s.isImporting,
          'isImporting',
          isTrue,
        ),
        isA<DocumentsState>()
            .having((DocumentsState s) => s.isImporting, 'isImporting', isFalse)
            .having((DocumentsState s) => s.failure, 'failure', isNull),
      ],
    );

    blocTest<DocumentsBloc, DocumentsState>(
      'surfaces a real import failure',
      build: build,
      setUp: () {
        when(() => importDocument(any())).thenAnswer(
          (_) async => const Err<Document>(PdfFailure()),
        );
      },
      act: (DocumentsBloc bloc) => bloc.add(
        const DocumentImportRequested(
          source: DocumentSource.scanner,
          defaultName: 'New Document',
        ),
      ),
      expect: () => <Matcher>[
        isA<DocumentsState>().having(
          (DocumentsState s) => s.isImporting,
          'isImporting',
          isTrue,
        ),
        isA<DocumentsState>().having(
          (DocumentsState s) => s.failure,
          'failure',
          isA<PdfFailure>(),
        ),
      ],
    );

    blocTest<DocumentsBloc, DocumentsState>(
      'drops a second import while one is already running',
      build: build,
      setUp: () {
        when(() => importDocument(any())).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return Ok<Document>(_document);
        });
      },
      act: (DocumentsBloc bloc) => bloc
        ..add(
          const DocumentImportRequested(
            source: DocumentSource.files,
            defaultName: 'New Document',
          ),
        )
        ..add(
          const DocumentImportRequested(
            source: DocumentSource.photos,
            defaultName: 'New Document',
          ),
        ),
      wait: const Duration(milliseconds: 200),
      verify: (_) => verify(() => importDocument(any())).called(1),
    );
  });

  group('signature', () {
    blocTest<DocumentsBloc, DocumentsState>(
      'delegates the toggle and stays quiet on success',
      build: build,
      setUp: () {
        when(() => toggleSignature(any())).thenAnswer(
          (_) async => const Ok<void>(null),
        );
      },
      act: (DocumentsBloc bloc) =>
          bloc.add(DocumentSignatureToggled(_document)),
      expect: () => <DocumentsState>[],
      verify: (_) => verify(() => toggleSignature(_document)).called(1),
    );

    blocTest<DocumentsBloc, DocumentsState>(
      'reports a failed toggle',
      build: build,
      setUp: () {
        when(() => toggleSignature(any())).thenAnswer(
          (_) async => const Err<void>(DatabaseFailure()),
        );
      },
      act: (DocumentsBloc bloc) =>
          bloc.add(DocumentSignatureToggled(_document)),
      expect: () => <Matcher>[
        isA<DocumentsState>().having(
          (DocumentsState s) => s.failure,
          'failure',
          isA<DatabaseFailure>(),
        ),
      ],
    );
  });
}
