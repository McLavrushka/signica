/// A single application action. One public `call`, no hidden state.
abstract interface class UseCase<Out, In> {
  Future<Out> call(In params);
}

/// A use case that exposes a continuously updating source of truth.
abstract interface class StreamUseCase<Out, In> {
  Stream<Out> call(In params);
}

/// A use case that computes its result synchronously and without I/O.
abstract interface class SyncUseCase<Out, In> {
  Out call(In params);
}
