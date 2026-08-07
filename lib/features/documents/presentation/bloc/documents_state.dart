part of 'documents_bloc.dart';

enum DocumentsStatus { initial, loading, ready }

class DocumentsState extends Equatable {
  const DocumentsState({
    this.status = DocumentsStatus.initial,
    this.documents = const <Document>[],
    this.query = '',
    this.filter = DocumentsFilter.all,
    this.isImporting = false,
    this.failure,
  });

  final DocumentsStatus status;
  final List<Document> documents;
  final String query;
  final DocumentsFilter filter;

  /// True while a picker is open or a PDF is being generated.
  final bool isImporting;

  /// Last error worth showing to the user. A cancelled picker never lands here.
  final Failure? failure;

  /// The empty state is only shown for an untouched library, not for a search
  /// or filter that happens to match nothing.
  bool get isEmptyLibrary =>
      status == DocumentsStatus.ready &&
      documents.isEmpty &&
      query.isEmpty &&
      filter == DocumentsFilter.all;

  DocumentsState copyWith({
    DocumentsStatus? status,
    List<Document>? documents,
    String? query,
    DocumentsFilter? filter,
    bool? isImporting,
    Failure? failure,
    bool clearFailure = false,
  }) => DocumentsState(
    status: status ?? this.status,
    documents: documents ?? this.documents,
    query: query ?? this.query,
    filter: filter ?? this.filter,
    isImporting: isImporting ?? this.isImporting,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    documents,
    query,
    filter,
    isImporting,
    failure,
  ];
}
