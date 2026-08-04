import 'package:flutter_test/flutter_test.dart';
import 'package:signica/features/documents/domain/use_cases/resolve_document_name.dart';

void main() {
  const ResolveDocumentName resolve = ResolveDocumentName();

  String call(String desired, List<String> existing) => resolve(
    ResolveDocumentNameParams(desiredName: desired, existingNames: existing),
  );

  group('ResolveDocumentName', () {
    test('keeps the name when nothing collides', () {
      expect(call('Resume', <String>['Contract']), 'Resume');
    });

    test('appends 2 for the first collision', () {
      expect(call('Resume', <String>['Resume']), 'Resume 2');
    });

    test('skips numbers that are already taken', () {
      expect(
        call('Resume', <String>['Resume', 'Resume 2', 'Resume 3']),
        'Resume 4',
      );
    });

    test('fills a gap in the sequence', () {
      expect(call('Resume', <String>['Resume', 'Resume 3']), 'Resume 2');
    });

    test('compares case-insensitively, like the iOS Files app', () {
      expect(call('Resume', <String>['resume']), 'Resume 2');
    });

    test('treats a trailing number as part of the name', () {
      expect(call('Resume 2', <String>['Resume 2']), 'Resume 2 2');
    });

    test('trims the incoming name', () {
      expect(call('  Resume  ', <String>['Resume']), 'Resume 2');
    });
  });
}
