/// Every user-visible string lives in `assets/translations/en.json`; these are
/// the keys, so a typo fails at review time instead of rendering raw JSON paths.
abstract final class TranslationKeys {
  static const String appTitle = 'app.title';

  static const String filterAll = 'filters.all';
  static const String filterSigned = 'filters.signed';
  static const String filterUnsigned = 'filters.unsigned';

  static const String documentDefaultName = 'documents.default_name';
  static const String documentSignedBadge = 'documents.signed_badge';
  static const String documentsEmptyTitle = 'documents.empty_title';
  static const String documentsEmptySubtitle = 'documents.empty_subtitle';
  static const String documentsSearchHint = 'documents.search_hint';

  static const String sourceSheetTitle = 'sources.sheet_title';
  static const String sourceFiles = 'sources.files';
  static const String sourcePhotos = 'sources.photos';
  static const String sourceScanner = 'sources.scanner';

  static const String actionAddDocument = 'actions.add_document';
  static const String actionSelect = 'actions.select';
  static const String actionSelectAll = 'actions.select_all';
  static const String actionDeselectAll = 'actions.deselect_all';
  static const String actionDelete = 'actions.delete';
  static const String actionShare = 'actions.share';
  static const String actionPrint = 'actions.print';
  static const String actionConfirm = 'actions.confirm';

  static const String errorImportFailed = 'errors.import_failed';
  static const String errorDeleteFailed = 'errors.delete_failed';
  static const String errorPermissionDenied = 'errors.permission_denied';
}
