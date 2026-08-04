import 'package:injectable/injectable.dart';
import 'package:signica/core/use_case.dart';

/// Parameters for [ResolveDocumentName].
class ResolveDocumentNameParams {
  const ResolveDocumentNameParams({
    required this.desiredName,
    required this.existingNames,
  });

  final String desiredName;
  final List<String> existingNames;
}

/// Resolves a name collision the way iOS does: `Name`, then `Name 2`,
/// `Name 3`, and so on.
///
/// Pure and synchronous — the entire de-duplication rule is testable without
/// touching the database.
@injectable
class ResolveDocumentName
    implements SyncUseCase<String, ResolveDocumentNameParams> {
  const ResolveDocumentName();

  @override
  String call(ResolveDocumentNameParams params) {
    final String desired = params.desiredName.trim();
    final Set<String> taken = params.existingNames
        .map((String name) => name.trim().toLowerCase())
        .toSet();

    if (!taken.contains(desired.toLowerCase())) {
      return desired;
    }

    // iOS starts at 2 for the first duplicate.
    for (int suffix = 2; ; suffix++) {
      final String candidate = '$desired $suffix';
      if (!taken.contains(candidate.toLowerCase())) {
        return candidate;
      }
    }
  }
}
