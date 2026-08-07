import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signica/app/di/injection.dart';
import 'package:signica/app/l10n/translation_keys.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_spacing.dart';
import 'package:signica/core/failure.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/entities/document_source.dart';
import 'package:signica/features/documents/domain/entities/documents_filter.dart';
import 'package:signica/features/documents/presentation/bloc/documents_bloc.dart';
import 'package:signica/features/documents/presentation/widgets/add_source_overlay.dart';
import 'package:signica/features/documents/presentation/widgets/bottom_bar_shell.dart';
import 'package:signica/features/documents/presentation/widgets/content_sheet.dart';
import 'package:signica/features/documents/presentation/widgets/document_actions_menu.dart';
import 'package:signica/features/documents/presentation/widgets/documents_bottom_chrome.dart';
import 'package:signica/features/documents/presentation/widgets/documents_header.dart';
import 'package:signica/features/documents/presentation/widgets/documents_menu.dart';
import 'package:signica/features/documents/presentation/widgets/header_menu_layer.dart';
import 'package:signica/features/documents/presentation/widgets/selection_bottom_bar.dart';

/// The single screen of the app.
@RoutePage()
class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<DocumentsBloc>(
    create: (_) => getIt<DocumentsBloc>()..add(const DocumentsSubscribed()),
    child: const DocumentsView(),
  );
}

/// Composition of the screen: dark header, rounded content sheet, and the
/// floating chrome on top of both. Owns presentation-only state; document
/// data comes from [DocumentsBloc].
@visibleForTesting
class DocumentsView extends StatefulWidget {
  const DocumentsView({super.key});

  @override
  State<DocumentsView> createState() => _DocumentsViewState();
}

class _DocumentsViewState extends State<DocumentsView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _query = TextEditingController();
  final FocusNode _queryFocus = FocusNode();

  /// Drives the source-picker morph; shared so the sheet blur and the pill
  /// rise stay in sync.
  late final AnimationController _sourcesMorph = AnimationController(
    vsync: this,
    duration: BottomBarMetrics.morphDuration,
  );
  late final Animation<double> _sources = CurvedAnimation(
    parent: _sourcesMorph,
    curve: BottomBarMetrics.morphCurve,
    reverseCurve: BottomBarMetrics.morphCurve.flipped,
  );

  BottomChromeMode _mode = BottomChromeMode.idle;
  bool _isMenuOpen = false;

  /// Null while not selecting; a set of ids while in select mode.
  Set<String>? _selection;

  /// The document whose actions menu is open, if any.
  String? _actionsDocumentId;

  @override
  void dispose() {
    _query.dispose();
    _queryFocus.dispose();
    _sourcesMorph.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomBarInset = BottomBarMetrics.reservedHeight(context);

    // The screen paints its own chrome instead of using a Scaffold, but text
    // still needs a Material ancestor for its default style.
    return Material(
      color: AppColors.header,
      child: BlocConsumer<DocumentsBloc, DocumentsState>(
        listenWhen: (DocumentsState previous, DocumentsState current) =>
            current.failure != null && previous.failure != current.failure,
        listener: (BuildContext context, DocumentsState state) =>
            _showFailure(context, state.failure!),
        builder: (BuildContext context, DocumentsState state) =>
            GestureDetector(
              // A tap outside the field only drops the keyboard, as on iOS.
              behavior: HitTestBehavior.opaque,
              onTap: _dismissKeyboard,
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      _HeaderArea(
                        selectedCount: _selection?.length,
                        onMenuTap: _openMenu,
                        onToggleSelectAll: () => _toggleSelectAll(state),
                        onCloseSelection: _exitSelection,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Expanded(
                        child: ContentSheet(
                          state: state,
                          selection: _selection,
                          highlightedId: _actionsDocumentId,
                          bottomInset: bottomBarInset,
                          sourcesProgress: _sources,
                          onFilterChanged: (DocumentsFilter filter) => context
                              .read<DocumentsBloc>()
                              .add(DocumentsFilterChanged(filter)),
                          onDocumentTap: _onDocumentTap,
                          onDocumentLongPress: _selection == null
                              ? _openActions
                              : null,
                          onSourceSelected: _import,
                        ),
                      ),
                    ],
                  ),
                  AnimatedBuilder(
                    animation: _sources,
                    builder: (BuildContext context, _) => AddSourceOverlay(
                      progress: _sources.value,
                      bottomInset: bottomBarInset,
                      onSourceSelected: _import,
                      onDismiss: _closeBottomOverlays,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _selection == null
                        ? DocumentsBottomChrome(
                            mode: _mode,
                            searchController: _query,
                            searchFocusNode: _queryFocus,
                            onSearchTap: _openSearch,
                            onAddTap: _openSources,
                            onCloseTap: _closeBottomOverlays,
                            onQueryChanged: (String value) => context
                                .read<DocumentsBloc>()
                                .add(DocumentsQueryChanged(value)),
                          )
                        : SelectionBottomBar(
                            hasSelection: _selection!.isNotEmpty,
                            onDelete: _deleteSelected,
                            onShare: _shareSelected,
                          ),
                  ),
                  HeaderMenuLayer(
                    isOpen: _isMenuOpen,
                    onDismiss: _closeMenu,
                    child: DocumentsMenu(
                      onSelect: _enterSelection,
                      onAddDocument: () {
                        _closeMenu();
                        _openSources();
                      },
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  void _openSearch() {
    setState(() => _mode = BottomChromeMode.search);
    _queryFocus.requestFocus();
  }

  void _openSources() {
    setState(() => _mode = BottomChromeMode.sources);
    unawaited(_sourcesMorph.forward());
  }

  void _closeBottomOverlays() {
    if (_mode == BottomChromeMode.search) {
      _query.clear();
      context.read<DocumentsBloc>().add(const DocumentsQueryChanged(''));
      _queryFocus.unfocus();
    }
    setState(() => _mode = BottomChromeMode.idle);
    unawaited(_sourcesMorph.reverse());
  }

  void _dismissKeyboard() {
    if (_queryFocus.hasFocus) {
      _queryFocus.unfocus();
    }
  }

  void _import(DocumentSource source) {
    if (_mode == BottomChromeMode.sources) {
      setState(() => _mode = BottomChromeMode.idle);
      unawaited(_sourcesMorph.reverse());
    }
    context.read<DocumentsBloc>().add(
      DocumentImportRequested(
        source: source,
        defaultName: TranslationKeys.documentDefaultName.tr(),
      ),
    );
  }

  void _onDocumentTap(Document document) {
    if (_selection case final Set<String> selection) {
      setState(() {
        _selection = selection.contains(document.id)
            ? (Set<String>.from(selection)..remove(document.id))
            : (Set<String>.from(selection)..add(document.id));
      });
      return;
    }
    // Signing is simplified to a single tap, as the assignment asks.
    context.read<DocumentsBloc>().add(DocumentSignatureToggled(document));
  }

  void _openMenu() => setState(() => _isMenuOpen = true);

  void _closeMenu() => setState(() => _isMenuOpen = false);

  void _enterSelection() {
    _closeMenu();
    setState(() => _selection = <String>{});
  }

  void _exitSelection() => setState(() => _selection = null);

  /// The action mirrors its label: "Select All" while nothing is picked,
  /// "Deselect All (n)" as soon as something is.
  void _toggleSelectAll(DocumentsState state) {
    setState(() {
      _selection = _selection!.isEmpty
          ? state.documents.map((Document document) => document.id).toSet()
          : <String>{};
    });
  }

  void _deleteSelected() {
    context.read<DocumentsBloc>().add(DocumentsDeleted(_selection!.toList()));
    _exitSelection();
  }

  void _shareSelected() {
    final DocumentsState state = context.read<DocumentsBloc>().state;
    final List<Document> selected = state.documents
        .where((Document document) => _selection!.contains(document.id))
        .toList();
    context.read<DocumentsBloc>().add(DocumentsShared(selected));
  }

  /// Opens the actions menu under the card the long press started on, the way
  /// a context menu behaves on iOS.
  Future<void> _openActions(Document document, Rect cardBounds) async {
    final DocumentsBloc bloc = context.read<DocumentsBloc>();
    setState(() => _actionsDocumentId = document.id);

    await showDocumentActions(
      context,
      anchor: cardBounds,
      onPrint: () => bloc.add(DocumentPrinted(document)),
      onShare: () => bloc.add(DocumentsShared(<Document>[document])),
      onDelete: () => bloc.add(DocumentsDeleted(<String>[document.id])),
    );

    if (mounted) {
      setState(() => _actionsDocumentId = null);
    }
  }

  void _showFailure(BuildContext context, Failure failure) {
    // `PickerCancelled` never reaches here (the bloc swallows it), but the
    // switch is exhaustive over a sealed `Failure` and must list it anyway.
    final String message = switch (failure) {
      PermissionDenied() => TranslationKeys.errorPermissionDenied,
      DatabaseFailure() => TranslationKeys.errorDeleteFailed,
      StorageFailure() ||
      PdfFailure() ||
      PickerCancelled() ||
      UnexpectedFailure() => TranslationKeys.errorImportFailed,
    };

    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => CupertinoAlertDialog(
        content: Text(message.tr()),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(TranslationKeys.actionConfirm.tr()),
          ),
        ],
      ),
    );
  }
}

/// Dark strip at the top: the app header, or the select-mode header once
/// something is being picked.
class _HeaderArea extends StatelessWidget {
  const _HeaderArea({
    required this.selectedCount,
    required this.onMenuTap,
    required this.onToggleSelectAll,
    required this.onCloseSelection,
  });

  /// Null outside select mode.
  final int? selectedCount;

  final VoidCallback onMenuTap;
  final VoidCallback onToggleSelectAll;
  final VoidCallback onCloseSelection;

  @override
  Widget build(BuildContext context) {
    // The two states of the row have their own side padding in the design.
    final double sidePadding = selectedCount == null
        ? DocumentsHeader.horizontalPadding
        : DocumentsSelectionHeader.horizontalPadding;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          sidePadding,
          DocumentsHeader.topGap,
          sidePadding,
          0,
        ),
        child: selectedCount == null
            ? DocumentsHeader(onMenuTap: onMenuTap)
            : DocumentsSelectionHeader(
                selectedCount: selectedCount!,
                onToggleSelectAll: onToggleSelectAll,
                onClose: onCloseSelection,
              ),
      ),
    );
  }
}
