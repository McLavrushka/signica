import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:signica/core/failure.dart';
import 'package:signica/core/result.dart';
import 'package:signica/features/documents/data/db/app_database.dart';
import 'package:signica/features/documents/data/db/documents_dao.dart';
import 'package:signica/features/documents/data/repositories/documents_repository_impl.dart';
import 'package:signica/features/documents/data/sources/file_storage.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/entities/documents_filter.dart';

class _MockDao extends Mock implements DocumentsDao {}

class _MockStorage extends Mock implements FileStorage {}

const String _base = '/container/Documents';

DocumentRow _row({String? lastPreview}) => DocumentRow(
  id: '1',
  name: 'Contract',
  nameFolded: 'contract',
  filePath: 'documents/1.pdf',
  firstPagePreviewPath: 'previews/1-first.png',
  lastPagePreviewPath: lastPreview,
  pageCount: 2,
  createdAt: DateTime(2025, 4, 12),
  isSigned: false,
);

Document _entity({String? lastPreview}) => Document(
  id: '1',
  name: 'Contract',
  filePath: '$_base/documents/1.pdf',
  firstPagePreviewPath: '$_base/previews/1-first.png',
  lastPagePreviewPath: lastPreview,
  pageCount: 2,
  createdAt: DateTime(2025, 4, 12),
);

void main() {
  late _MockDao dao;
  late _MockStorage storage;
  late DocumentsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_row());
    registerFallbackValue(DocumentsFilter.all);
  });

  setUp(() {
    dao = _MockDao();
    storage = _MockStorage();
    repository = DocumentsRepositoryImpl(dao, storage);

    // The real storage strips and re-adds the container prefix; these stubs do
    // the same thing so the test pins the direction of the conversion, not the
    // path arithmetic, which `path` already owns.
    when(() => storage.absolute(any())).thenAnswer(
      (Invocation i) => '$_base/${i.positionalArguments.first as String}',
    );
    when(() => storage.relative(any())).thenAnswer(
      (Invocation i) =>
          (i.positionalArguments.first as String).replaceFirst('$_base/', ''),
    );
  });

  /// iOS moves the app container between installs, so an absolute path written
  /// into the database stops resolving after an update. Rows therefore hold
  /// relative paths and entities absolute ones — this is the seam where that
  /// happens, in both directions.
  group('path round trip', () {
    test('reading rebuilds paths against the current container', () async {
      when(
        () => dao.watch(
          query: any(named: 'query'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer(
        (_) => Stream<List<DocumentRow>>.value(<DocumentRow>[_row()]),
      );

      final Result<List<Document>> first = await repository.watch().first;
      final Document document = (first as Ok<List<Document>>).value.single;

      expect(document.filePath, '$_base/documents/1.pdf');
      expect(document.firstPagePreviewPath, '$_base/previews/1-first.png');
    });

    test('a null last preview survives the trip as null', () async {
      when(
        () => dao.watch(
          query: any(named: 'query'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer(
        (_) => Stream<List<DocumentRow>>.value(<DocumentRow>[_row()]),
      );

      final Result<List<Document>> first = await repository.watch().first;

      expect(
        (first as Ok<List<Document>>).value.single.lastPagePreviewPath,
        isNull,
      );
    });

    test('writing strips the container back off', () async {
      when(() => dao.insertRow(any())).thenAnswer((_) async {});

      await repository.add(_entity(lastPreview: '$_base/previews/1-last.png'));

      final DocumentRow stored =
          verify(() => dao.insertRow(captureAny())).captured.single
              as DocumentRow;
      expect(stored.filePath, 'documents/1.pdf');
      expect(stored.firstPagePreviewPath, 'previews/1-first.png');
      expect(stored.lastPagePreviewPath, 'previews/1-last.png');
    });

    test(
      'the caller gets its own absolute paths back, not the stored ones',
      () async {
        when(() => dao.insertRow(any())).thenAnswer((_) async {});

        final Result<Document> result = await repository.add(_entity());

        expect(
          (result as Ok<Document>).value.filePath,
          '$_base/documents/1.pdf',
        );
      },
    );
  });

  group('deleteMany', () {
    test('rows go before files', () async {
      when(() => dao.byIds(any())).thenAnswer(
        (_) async => <DocumentRow>[_row(lastPreview: 'previews/1-last.png')],
      );
      when(() => dao.deleteByIds(any())).thenAnswer((_) async {});
      when(() => storage.deleteIfExists(any())).thenAnswer((_) async {});

      await repository.deleteMany(<String>['1']);

      verifyInOrder(<Future<void> Function()>[
        () => dao.deleteByIds(<String>['1']),
        () => storage.deleteIfExists('documents/1.pdf'),
      ]);
    });

    test('every file of the document is removed', () async {
      when(() => dao.byIds(any())).thenAnswer(
        (_) async => <DocumentRow>[_row(lastPreview: 'previews/1-last.png')],
      );
      when(() => dao.deleteByIds(any())).thenAnswer((_) async {});
      when(() => storage.deleteIfExists(any())).thenAnswer((_) async {});

      await repository.deleteMany(<String>['1']);

      verify(() => storage.deleteIfExists('documents/1.pdf')).called(1);
      verify(() => storage.deleteIfExists('previews/1-first.png')).called(1);
      verify(() => storage.deleteIfExists('previews/1-last.png')).called(1);
    });
  });

  /// No exception crosses a layer boundary — including out of the stream that
  /// feeds the grid, which is the one that used to.
  group('failures', () {
    test('a broken stream yields a failure instead of throwing', () async {
      when(
        () => dao.watch(
          query: any(named: 'query'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer(
        (_) => Stream<List<DocumentRow>>.error(StateError('db is gone')),
      );

      final Result<List<Document>> first = await repository.watch().first;

      expect(first.failureOrNull, isA<DatabaseFailure>());
    });

    test('a failed name lookup comes back as a failure', () async {
      when(() => dao.allNames()).thenThrow(StateError('db is gone'));

      final Result<List<String>> result = await repository.allNames();

      expect(result.failureOrNull, isA<DatabaseFailure>());
    });

    test('a failed insert comes back as a failure', () async {
      when(() => dao.insertRow(any())).thenThrow(StateError('db is gone'));

      final Result<Document> result = await repository.add(_entity());

      expect(result.failureOrNull, isA<DatabaseFailure>());
    });

    test('a failed delete is reported as storage, not database', () async {
      when(() => dao.byIds(any())).thenThrow(StateError('db is gone'));

      final Result<void> result = await repository.deleteMany(<String>['1']);

      expect(result.failureOrNull, isA<StorageFailure>());
    });

    test('the filter reaches the dao untouched', () async {
      when(
        () => dao.watch(
          query: any(named: 'query'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) => Stream<List<DocumentRow>>.value(<DocumentRow>[]));

      await repository
          .watch(query: 'res', filter: DocumentsFilter.signed)
          .first;

      verify(
        () => dao.watch(query: 'res', filter: DocumentsFilter.signed),
      ).called(1);
    });
  });
}
