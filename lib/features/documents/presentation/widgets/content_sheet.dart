import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_radius.dart';
import 'package:signica/app/theme/app_spacing.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/entities/document_source.dart';
import 'package:signica/features/documents/domain/entities/documents_filter.dart';
import 'package:signica/features/documents/presentation/bloc/documents_bloc.dart';
import 'package:signica/features/documents/presentation/widgets/documents_empty_state.dart';
import 'package:signica/features/documents/presentation/widgets/documents_filter_bar.dart';
import 'package:signica/features/documents/presentation/widgets/documents_grid.dart';

/// The rounded sheet under the dark header: filter bar, then either the grid
/// or the empty state. Owns the shared side inset and the blur the source
/// picker puts over the documents (the header stays sharp).
class ContentSheet extends StatelessWidget {
  const ContentSheet({
    required this.state,
    required this.selection,
    required this.highlightedId,
    required this.bottomInset,
    required this.sourcesProgress,
    required this.onFilterChanged,
    required this.onDocumentTap,
    required this.onDocumentLongPress,
    required this.onSourceSelected,
    super.key,
  });

  /// Side inset of the grid, the empty state, and the source stack that floats
  /// over them. Wider than the header's, so cards sit in from the sheet edge.
  static const double horizontalInset = 28;

  /// Not read from a spec: the mock-up bakes the grid in already blurred, so
  /// this is matched to the render.
  static const double _blurSigma = 8;

  final DocumentsState state;
  final Set<String>? selection;
  final String? highlightedId;
  final double bottomInset;

  /// Drives the blur. An [Animation] rather than a value so only the filter
  /// rebuilds per frame — the grid under it is handed through untouched.
  final Animation<double> sourcesProgress;

  final ValueChanged<DocumentsFilter> onFilterChanged;
  final ValueChanged<Document> onDocumentTap;
  final void Function(Document document, Rect cardBounds)? onDocumentLongPress;
  final ValueChanged<DocumentSource> onSourceSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.surface),
      ),
      child: ColoredBox(
        color: AppColors.surface,
        child: _SheetBlur(
          progress: sourcesProgress,
          child: Column(
            // Without this the grid shrink-wraps its cards and a half-full row
            // ends up centred.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: AppSpacing.s16),
              DocumentsFilterBar(
                filter: state.filter,
                onChanged: onFilterChanged,
              ),
              Expanded(
                child: state.isEmptyLibrary
                    ? DocumentsEmptyState(
                        onSourceSelected: onSourceSelected,
                        bottomInset: bottomInset,
                      )
                    : DocumentsGrid(
                        documents: state.documents,
                        selectedIds: selection,
                        highlightedId: highlightedId,
                        bottomInset: bottomInset,
                        onDocumentTap: onDocumentTap,
                        onDocumentLongPress: onDocumentLongPress,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Blurs the sheet while the source picker is open.
///
/// A `BackdropFilter` blurs what is already painted behind it, so it goes over
/// the content as a sibling rather than around it — wrapped around the grid it
/// would blur the empty surface underneath and leave the cards sharp.
///
/// Rebuilds on every frame of the morph, which is why [child] is built once
/// outside the builder: the grid has no business rebuilding because a filter
/// above it changed sigma.
class _SheetBlur extends StatelessWidget {
  const _SheetBlur({required this.progress, required this.child});

  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: progress,
            // At rest the filter is not built at all — a BackdropFilter costs a
            // saveLayer on every frame the grid scrolls, for a blur of zero.
            builder: (BuildContext context, _) => progress.value <= 0
                ? const SizedBox.shrink()
                : IgnorePointer(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: ContentSheet._blurSigma * progress.value,
                        sigmaY: ContentSheet._blurSigma * progress.value,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
