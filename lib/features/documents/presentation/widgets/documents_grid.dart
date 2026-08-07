import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:signica/app/theme/app_motion.dart';
import 'package:signica/app/theme/app_opacity.dart';
import 'package:signica/app/theme/app_spacing.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/presentation/widgets/content_sheet.dart';
import 'package:signica/features/documents/presentation/widgets/document_card.dart';

const double _columnGap = 19;

/// Grid of documents. Column count comes from the space given, not the
/// screen. A [Wrap], not a [GridView]: a [GridView] delegate wants a fixed
/// row height, which breaks once a card's name takes two lines.
class DocumentsGrid extends StatelessWidget {
  const DocumentsGrid({
    required this.documents,
    required this.onDocumentTap,
    this.onDocumentLongPress,
    this.selectedIds,
    this.highlightedId,
    this.bottomInset = 0,
    super.key,
  });

  /// Side padding of the grid, owned by the sheet it is drawn on.
  static const double horizontalPadding = ContentSheet.horizontalInset;

  /// Air between the filter bar and the first row of cards.
  static const double topPadding = AppSpacing.s32;

  /// Width a card is sized to when there is room. This is the one number the
  /// grid is allowed to hold, because it is what decides how many columns fit;
  /// every other size here is derived from the space available.
  static const double preferredItemWidth = 150;

  final List<Document> documents;
  final ValueChanged<Document> onDocumentTap;

  /// Called with the document and with the rectangle its card occupies on
  /// screen, which is where the actions menu has to open.
  final void Function(Document document, Rect cardBounds)? onDocumentLongPress;

  /// Null outside select mode.
  final Set<String>? selectedIds;

  /// While the actions menu is open the design fades every card but the one
  /// the menu belongs to.
  final String? highlightedId;

  /// Space kept free under the last row for the floating bottom bar.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double available = constraints.maxWidth - horizontalPadding * 2;
        final int columns = _columnsFor(available);
        final double cardWidth =
            (available - _columnGap * (columns - 1)) / columns;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            bottomInset,
          ),
          child: Wrap(
            spacing: _columnGap,
            runSpacing: AppSpacing.s24,
            children: <Widget>[
              for (final Document document in documents)
                SizedBox(
                  width: cardWidth,
                  child: AnimatedOpacity(
                    // Everything but the card the menu belongs to drops back.
                    opacity:
                        highlightedId == null || highlightedId == document.id
                        ? 1
                        : AppOpacity.dimmed,
                    duration: AppMotion.fast,
                    child: DocumentCard(
                      key: ValueKey<String>(document.id),
                      document: document,
                      isSelected: selectedIds?.contains(document.id),
                      onTap: () => onDocumentTap(document),
                      onLongPress: onDocumentLongPress == null
                          ? null
                          : (Rect bounds) =>
                                onDocumentLongPress!(document, bounds),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// As many columns as fit at [preferredItemWidth], never fewer than two
  /// (a one-up grid reads as a list, not a grid). No ceiling — cards only
  /// ever end up at or above the preferred width.
  static int _columnsFor(double available) {
    final int fitting =
        ((available + _columnGap) / (preferredItemWidth + _columnGap)).floor();
    return math.max(2, fitting);
  }
}
