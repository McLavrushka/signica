part of 'documents_bloc.dart';

sealed class DocumentsEvent extends Equatable {
  const DocumentsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Subscribes to the repository stream for the current query and filter.
/// Re-added whenever either of them changes.
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

/// Runs the whole pick → store → persist flow for [source].
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

/// Emitted internally when the repository stream produces a new list.
final class _DocumentsReceived extends DocumentsEvent {
  const _DocumentsReceived(this.documents);

  final List<Document> documents;

  @override
  List<Object?> get props => <Object?>[documents];
}
