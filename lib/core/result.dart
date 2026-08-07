import 'package:signica/core/failure.dart';

/// Explicit success/failure return type.
///
/// Chosen over `dartz`/`fpdart` on purpose: the project needs exactly two
/// cases and Dart 3 sealed classes cover them with exhaustive `switch`,
/// without pulling a functional-programming library into the domain layer.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;

  const factory Result.err(Failure failure) = Err<T>;

  Failure? get failureOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final Failure failure) => failure,
  };

  /// Collapses both branches into a single value.
  R fold<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) => switch (this) {
    Ok<T>(:final T value) => ok(value),
    Err<T>(:final Failure failure) => err(failure),
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
