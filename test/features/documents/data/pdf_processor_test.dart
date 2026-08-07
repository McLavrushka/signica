import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:signica/features/documents/data/sources/file_storage.dart';
import 'package:signica/features/documents/data/sources/pdf_processor.dart';

class _MockStorage extends Mock implements FileStorage {}

void main() {
  late PdfProcessor processor;

  setUp(() {
    processor = PdfProcessor(_MockStorage());
  });

  group('buildPdfFromImages', () {
    /// The iOS scanner plugin writes each page with `try?` and appends the
    /// path whether or not the write succeeded, so a full disk produces paths
    /// to files that never existed. The read has to fail as a file system
    /// error naming the page — that is what makes it a [StorageFailure] one
    /// layer up instead of an unclassified one.
    test('a page that was never written fails as a file system error', () {
      final String missing = '${Directory.systemTemp.path}/no-such-page.jpg';

      expect(
        () => processor.buildPdfFromImages(
          imagePaths: <String>[missing],
          targetPath: '${Directory.systemTemp.path}/out.pdf',
        ),
        throwsA(
          isA<PathNotFoundException>().having(
            (PathNotFoundException e) => e.path,
            'path',
            missing,
          ),
        ),
      );
    });
  });
}
