import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
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

part 'documents_event.dart';
part 'documents_state.dart';

/// Owns the document list, active query/filter, and import lifecycle.
/// Search bar UI state (open/closed, animation) lives in the widget instead.
@injectable
class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  DocumentsBloc(
    this._watchDocuments,
    this._importDocument,
    this._toggleSignature,
    this._deleteDocuments,
    this._shareDocuments,
    this._printDocument,
  ) : super(const DocumentsState()) {
    on<DocumentsSubscribed>(_onSubscribed, transformer: restartable());
    on<DocumentsQueryChanged>(
      _onQueryChanged,
      transformer: _debounce(_searchDebounce),
    );
    on<DocumentsFilterChanged>(_onFilterChanged);
    on<DocumentImportRequested>(_onImportRequested, transformer: droppable());
    on<DocumentSignatureToggled>(
      (DocumentSignatureToggled event, Emitter<DocumentsState> emit) =>
          _reportFailure(emit, _toggleSignature(event.document)),
    );
    on<DocumentsDeleted>(
      (DocumentsDeleted event, Emitter<DocumentsState> emit) =>
          _reportFailure(emit, _deleteDocuments(event.ids)),
    );
    on<DocumentsShared>(
      (DocumentsShared event, Emitter<DocumentsState> emit) =>
          _reportFailure(emit, _shareDocuments(event.documents)),
      transformer: droppable(),
    );
    on<DocumentPrinted>(
      (DocumentPrinted event, Emitter<DocumentsState> emit) =>
          _reportFailure(emit, _printDocument(event.document)),
      transformer: droppable(),
    );
    on<_DocumentsReceived>(_onReceived);
  }

  static const Duration _searchDebounce = Duration(milliseconds: 200);

  final WatchDocuments _watchDocuments;
  final ImportDocument _importDocument;
  final ToggleSignature _toggleSignature;
  final DeleteDocuments _deleteDocuments;
  final ShareDocuments _shareDocuments;
  final PrintDocument _printDocument;

  Future<void> _onSubscribed(
    DocumentsSubscribed event,
    Emitter<DocumentsState> emit,
  ) async {
    if (state.status == DocumentsStatus.initial) {
      emit(state.copyWith(status: DocumentsStatus.loading));
    }

    // `restartable` cancels the previous subscription, so changing the query
    // or the filter simply re-runs this handler.
    await emit.onEach<Result<List<Document>>>(
      _watchDocuments(
        WatchDocumentsParams(query: state.query, filter: state.filter),
      ),
      onData: (Result<List<Document>> result) =>
          add(_DocumentsReceived(result)),
    );
  }

  void _onReceived(_DocumentsReceived event, Emitter<DocumentsState> emit) {
    emit(
      event.result.fold(
        ok: (List<Document> documents) =>
            state.copyWith(status: DocumentsStatus.ready, documents: documents),
        // The list already on screen stays: a query that failed to reload is
        // still better than a grid that empties itself under the error.
        err: (Failure failure) =>
            state.copyWith(status: DocumentsStatus.ready, failure: failure),
      ),
    );
  }

  void _onQueryChanged(
    DocumentsQueryChanged event,
    Emitter<DocumentsState> emit,
  ) {
    if (event.query == state.query) return;
    emit(state.copyWith(query: event.query));
    add(const DocumentsSubscribed());
  }

  void _onFilterChanged(
    DocumentsFilterChanged event,
    Emitter<DocumentsState> emit,
  ) {
    if (event.filter == state.filter) return;
    emit(state.copyWith(filter: event.filter));
    add(const DocumentsSubscribed());
  }

  Future<void> _onImportRequested(
    DocumentImportRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(state.copyWith(isImporting: true, clearFailure: true));

    final Result<Document> result = await _importDocument(
      ImportDocumentParams(
        source: event.source,
        defaultName: event.defaultName,
      ),
    );

    emit(
      result.fold(
        ok: (_) => state.copyWith(isImporting: false),
        // Backing out of a picker is a normal action, not an error to report.
        err: (Failure failure) => failure is PickerCancelled
            ? state.copyWith(isImporting: false)
            : state.copyWith(isImporting: false, failure: failure),
      ),
    );
  }

  /// Runs a use case whose only visible outcome is failure; success refreshes
  /// through the drift stream instead of an emit.
  Future<void> _reportFailure(
    Emitter<DocumentsState> emit,
    Future<Result<void>> action,
  ) async {
    final Result<void> result = await action;
    if (result.failureOrNull case final Failure failure) {
      emit(state.copyWith(failure: failure));
    }
  }

  /// Debounces keystrokes, then keeps only the last query via `restartable`.
  static EventTransformer<T> _debounce<T>(Duration duration) =>
      (Stream<T> events, EventMapper<T> mapper) =>
          restartable<T>().call(events.debounce(duration), mapper);
}

extension _DebounceStream<T> on Stream<T> {
  Stream<T> debounce(Duration duration) {
    Timer? timer;
    late StreamController<T> controller;

    controller = StreamController<T>(
      onListen: () {
        listen(
          (T event) {
            timer?.cancel();
            timer = Timer(duration, () => controller.add(event));
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            controller.close();
          },
        );
      },
      onCancel: () => timer?.cancel(),
    );

    return controller.stream;
  }
}
