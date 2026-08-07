part of 'documents_bloc.dart';

sealed class DocumentsEvent extends Equatable {
  const DocumentsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class DocumentsSubscribed extends DocumentsEvent {
  const DocumentsSubscribed();
}

final class DocumentsQueryChanged extends DocumentsEvent {
  const DocumentsQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

final class DocumentsFilterChanged extends DocumentsEvent {
  const DocumentsFilterChanged(this.filter);

  final DocumentsFilter filter;

  @override
  List<Object?> get props => <Object?>[filter];
}

final class DocumentImportRequested extends DocumentsEvent {
  const DocumentImportRequested({
    required this.source,
    required this.defaultName,
  });

  final DocumentSource source;

  /// Localised "New Document"; the domain must not depend on easy_localization.
  final String defaultName;

  @override
  List<Object?> get props => <Object?>[source, defaultName];
}

final class DocumentSignatureToggled extends DocumentsEvent {
  const DocumentSignatureToggled(this.document);

  final Document document;

  @override
  List<Object?> get props => <Object?>[document];
}

final class DocumentsDeleted extends DocumentsEvent {
  const DocumentsDeleted(this.ids);

  final List<String> ids;

  @override
  List<Object?> get props => <Object?>[ids];
}

final class DocumentsShared extends DocumentsEvent {
  const DocumentsShared(this.documents);

  final List<Document> documents;

  @override
  List<Object?> get props => <Object?>[documents];
}

final class DocumentPrinted extends DocumentsEvent {
  const DocumentPrinted(this.document);

  final Document document;

  @override
  List<Object?> get props => <Object?>[document];
}

final class _DocumentsReceived extends DocumentsEvent {
  const _DocumentsReceived(this.result);

  final Result<List<Document>> result;

  @override
  List<Object?> get props => <Object?>[result];
}
