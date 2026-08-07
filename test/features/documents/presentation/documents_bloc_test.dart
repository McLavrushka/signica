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
import 'package:signica/features/documents/domain/use_cases/print_document.dart';
import 'package:signica/features/documents/domain/use_cases/share_documents.dart';
import 'package:signica/features/documents/domain/use_cases/toggle_signature.dart';
import 'package:signica/features/documents/domain/use_cases/watch_documents.dart';
import 'package:signica/features/documents/presentation/bloc/documents_bloc.dart';

class _MockWatchDocuments extends Mock implements WatchDocuments {}

class _MockImportDocument extends Mock implements ImportDocument {}

class _MockToggleSignature extends Mock implements ToggleSignature {}

class _MockDeleteDocuments extends Mock implements DeleteDocuments {}

class _MockShareDocuments extends Mock implements ShareDocuments {}

class _MockPrintDocument extends Mock implements PrintDocument {}

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
  late _MockShareDocuments shareDocuments;
  late _MockPrintDocument printDocument;

  setUpAll(() {
    registerFallbackValue(const WatchDocumentsParams());
    registerFallbackValue(
      const ImportDocumentParams(
        source: DocumentSource.files,
        defaultName: 'New Document',
      ),
    );
    registerFallbackValue(_document);
    registerFallbackValue(<Document>[_document]);
  });

  setUp(() {
    watchDocuments = _MockWatchDocuments();
    importDocument = _MockImportDocument();
    toggleSignature = _MockToggleSignature();
    deleteDocuments = _MockDeleteDocuments();
    shareDocuments = _MockShareDocuments();
    printDocument = _MockPrintDocument();

    when(() => watchDocuments(any())).thenAnswer(
      (_) => Stream<Result<List<Document>>>.value(
        Ok<List<Document>>(<Document>[_document]),
      ),
    );
  });

  DocumentsBloc build() => DocumentsBloc(
    watchDocuments,
    importDocument,
    toggleSignature,
    deleteDocuments,
    shareDocuments,
    printDocument,
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
            .having((DocumentsState s) => s.documents, 'documents', <Document>[
              _document,
            ]),
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
        final List<WatchDocumentsParams> calls = verify(
          () => watchDocuments(captureAny()),
        ).captured.cast<WatchDocumentsParams>();
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
        final List<WatchDocumentsParams> calls = verify(
          () => watchDocuments(captureAny()),
        ).captured.cast<WatchDocumentsParams>();
        expect(calls.last.filter, DocumentsFilter.signed);
      },
    );
  });

  group('import', () {
    blocTest<DocumentsBloc, DocumentsState>(
      'flags the import while it runs and clears it afterwards',
      build: build,
      setUp: () {
        when(
          () => importDocument(any()),
        ).thenAnswer((_) async => Ok<Document>(_document));
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
        when(
          () => importDocument(any()),
        ).thenAnswer((_) async => const Err<Document>(PickerCancelled()));
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
        when(
          () => importDocument(any()),
        ).thenAnswer((_) async => const Err<Document>(PdfFailure()));
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

  group('export', () {
    blocTest<DocumentsBloc, DocumentsState>(
      'sends the selected documents to the share sheet',
      build: build,
      setUp: () {
        when(
          () => shareDocuments(any()),
        ).thenAnswer((_) async => const Ok<void>(null));
      },
      act: (DocumentsBloc bloc) =>
          bloc.add(DocumentsShared(<Document>[_document])),
      expect: () => <DocumentsState>[],
      verify: (_) =>
          verify(() => shareDocuments(<Document>[_document])).called(1),
    );

    blocTest<DocumentsBloc, DocumentsState>(
      'reports a failed print',
      build: build,
      setUp: () {
        when(
          () => printDocument(any()),
        ).thenAnswer((_) async => const Err<void>(PdfFailure()));
      },
      act: (DocumentsBloc bloc) => bloc.add(DocumentPrinted(_document)),
      expect: () => <Matcher>[
        isA<DocumentsState>().having(
          (DocumentsState s) => s.failure,
          'failure',
          isA<PdfFailure>(),
        ),
      ],
    );
  });

  group('signature', () {
    blocTest<DocumentsBloc, DocumentsState>(
      'delegates the toggle and stays quiet on success',
      build: build,
      setUp: () {
        when(
          () => toggleSignature(any()),
        ).thenAnswer((_) async => const Ok<void>(null));
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
        when(
          () => toggleSignature(any()),
        ).thenAnswer((_) async => const Err<void>(DatabaseFailure()));
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

  group('deletion', () {
    blocTest<DocumentsBloc, DocumentsState>(
      'delegates the ids and stays quiet on success',
      build: build,
      setUp: () {
        when(
          () => deleteDocuments(any()),
        ).thenAnswer((_) async => const Ok<void>(null));
      },
      act: (DocumentsBloc bloc) =>
          bloc.add(const DocumentsDeleted(<String>['1', '2'])),
      // Nothing to emit: the grid reloads through the drift stream.
      expect: () => <DocumentsState>[],
      verify: (_) =>
          verify(() => deleteDocuments(<String>['1', '2'])).called(1),
    );

    blocTest<DocumentsBloc, DocumentsState>(
      'reports a failed delete',
      build: build,
      setUp: () {
        when(
          () => deleteDocuments(any()),
        ).thenAnswer((_) async => const Err<void>(StorageFailure()));
      },
      act: (DocumentsBloc bloc) =>
          bloc.add(const DocumentsDeleted(<String>['1'])),
      expect: () => <Matcher>[
        isA<DocumentsState>().having(
          (DocumentsState s) => s.failure,
          'failure',
          isA<StorageFailure>(),
        ),
      ],
    );
  });

  group('stream failures', () {
    // Expressible only because the repository hands failures back in the
    // stream instead of throwing past the bloc.
    blocTest<DocumentsBloc, DocumentsState>(
      'a database error in the list reaches the state',
      build: build,
      setUp: () {
        when(() => watchDocuments(any())).thenAnswer(
          (_) => Stream<Result<List<Document>>>.value(
            const Err<List<Document>>(DatabaseFailure()),
          ),
        );
      },
      act: (DocumentsBloc bloc) => bloc.add(const DocumentsSubscribed()),
      expect: () => <Matcher>[
        isA<DocumentsState>().having(
          (DocumentsState s) => s.status,
          'status',
          DocumentsStatus.loading,
        ),
        isA<DocumentsState>().having(
          (DocumentsState s) => s.failure,
          'failure',
          isA<DatabaseFailure>(),
        ),
      ],
    );

    // A failed reload must not blank the grid the user is looking at.
    blocTest<DocumentsBloc, DocumentsState>(
      'the documents already on screen survive the error',
      build: build,
      seed: () => DocumentsState(
        status: DocumentsStatus.ready,
        documents: <Document>[_document],
      ),
      setUp: () {
        when(() => watchDocuments(any())).thenAnswer(
          (_) => Stream<Result<List<Document>>>.value(
            const Err<List<Document>>(DatabaseFailure()),
          ),
        );
      },
      act: (DocumentsBloc bloc) => bloc.add(const DocumentsSubscribed()),
      expect: () => <Matcher>[
        isA<DocumentsState>().having(
          (DocumentsState s) => s.documents,
          'documents',
          <Document>[_document],
        ),
      ],
    );
  });

  group('export failures', () {
    blocTest<DocumentsBloc, DocumentsState>(
      'reports a failed share',
      build: build,
      setUp: () {
        when(
          () => shareDocuments(any()),
        ).thenAnswer((_) async => const Err<void>(StorageFailure()));
      },
      act: (DocumentsBloc bloc) =>
          bloc.add(DocumentsShared(<Document>[_document])),
      expect: () => <Matcher>[
        isA<DocumentsState>().having(
          (DocumentsState s) => s.failure,
          'failure',
          isA<StorageFailure>(),
        ),
      ],
    );

    blocTest<DocumentsBloc, DocumentsState>(
      'a successful print says nothing',
      build: build,
      setUp: () {
        when(
          () => printDocument(any()),
        ).thenAnswer((_) async => const Ok<void>(null));
      },
      act: (DocumentsBloc bloc) => bloc.add(DocumentPrinted(_document)),
      expect: () => <DocumentsState>[],
      verify: (_) => verify(() => printDocument(_document)).called(1),
    );
  });
}
