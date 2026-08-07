import 'package:equatable/equatable.dart';

/// Domain-level error. Data sources translate platform exceptions into these,
/// so neither the domain nor the presentation layer ever sees a raw exception.
sealed class Failure extends Equatable {
  const Failure({this.cause});

  final Object? cause;

  @override
  List<Object?> get props => <Object?>[runtimeType, cause];
}

/// The user dismissed a picker / scanner without choosing anything.
/// Not an error state for the UI — it just goes back to idle.
final class PickerCancelled extends Failure {
  const PickerCancelled();
}

/// The OS denied access to camera or photo library.
final class PermissionDenied extends Failure {
  const PermissionDenied({super.cause});
}

/// Reading, writing or deleting a file failed.
final class StorageFailure extends Failure {
  const StorageFailure({super.cause});
}

/// Building a PDF or rendering one of its pages failed.
final class PdfFailure extends Failure {
  const PdfFailure({super.cause});
}

/// A database operation failed.
final class DatabaseFailure extends Failure {
  const DatabaseFailure({super.cause});
}

/// Anything that escaped the cases above.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.cause});
}
