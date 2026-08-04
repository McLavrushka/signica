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
import 'package:signica/features/documents/domain/use_cases/toggle_signature.dart';
import 'package:signica/features/documents/domain/use_cases/watch_documents.dart';

part 'documents_event.dart';
part 'documents_state.dart';

/// Owns everything about *what* is on screen: the document list, the active
/// query and filter, and the import lifecycle.
///
/// It deliberately does not own how the search bar animates or whether it is
/// open — that is presentation-only state and lives in the widget.
@injectable
class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  DocumentsBloc(
    this._watchDocuments,
    this._importDocument,
    this._toggleSignature,
    this._deleteDocuments,
  ) : super(const DocumentsState()) {
    on<DocumentsSubscribed>(_onSubscribed, transformer: restartable());
    on<DocumentsQueryChanged>(
      _onQueryChanged,
      transformer: _debounce(_searchDebounce),
    );
    on<DocumentsFilterChanged>(_onFilterChanged);
    on<DocumentImportRequested>(_onImportRequested, transformer: droppable());
    on<DocumentSignatureToggled>(_onSignatureToggled);
    on<DocumentsDeleted>(_onDeleted);
    on<_DocumentsReceived>(_onReceived);
  }

  static const Duration _searchDebounce = Duration(milliseconds: 200);

  final WatchDocuments _watchDocuments;
  final ImportDocument _importDocument;
  final ToggleSignature _toggleSignature;
  final DeleteDocuments _deleteDocuments;

  Future<void> _onSubscribed(
    DocumentsSubscribed event,
    Emitter<DocumentsState> emit,
  ) async {
    if (state.status == DocumentsStatus.initial) {
      emit(state.copyWith(status: DocumentsStatus.loading));
    }

    // `restartable` cancels the previous subscription, so changing the query
    // or the filter simply re-runs this handler.
    await emit.onEach<List<Document>>(
      _watchDocuments(
        WatchDocumentsParams(query: state.query, filter: state.filter),
      ),
      onData: (List<Document> documents) => add(_DocumentsReceived(documents)),
    );
  }

  void _onReceived(_DocumentsReceived event, Emitter<DocumentsState> emit) {
    emit(
      state.copyWith(
        status: DocumentsStatus.ready,
        documents: event.documents,
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

  Future<void> _onSignatureToggled(
    DocumentSignatureToggled event,
    Emitter<DocumentsState> emit,
  ) async {
    final Result<void> result = await _toggleSignature(event.document);
    // The list itself refreshes through the drift stream.
    if (result.failureOrNull case final Failure failure) {
      emit(state.copyWith(failure: failure));
    }
  }

  Future<void> _onDeleted(
    DocumentsDeleted event,
    Emitter<DocumentsState> emit,
  ) async {
    final Result<void> result = await _deleteDocuments(event.ids);
    if (result.failureOrNull case final Failure failure) {
      emit(state.copyWith(failure: failure));
    }
  }

  /// Debounce keystrokes, then behave like `restartable` so only the last
  /// query survives.
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
