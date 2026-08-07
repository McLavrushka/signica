import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:signica/app/assets.dart';
import 'package:signica/app/l10n/translation_keys.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_spacing.dart';
import 'package:signica/app/theme/app_typography.dart';
import 'package:signica/features/documents/domain/entities/document_source.dart';
import 'package:signica/features/documents/presentation/widgets/content_sheet.dart';
import 'package:signica/features/documents/presentation/widgets/source_pill.dart';

const double _illustrationWidthFactor = 0.72;
const double _illustrationToTitleGap = 20;

/// Shown for an untouched library — not for a search or filter that happens to
/// match nothing (see `DocumentsState.isEmptyLibrary`). Scrolls rather than
/// clips when it doesn't fit (SE, larger Dynamic Type).
class DocumentsEmptyState extends StatelessWidget {
  const DocumentsEmptyState({
    required this.onSourceSelected,
    this.bottomInset = 0,
    super.key,
  });

  final ValueChanged<DocumentSource> onSourceSelected;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: ConstrainedBox(
            // Fill the sheet so the content centres, minus the space the bar
            // covers. `max` guards the one case that can go wrong: a bar
            // taller than the sheet would ask for a negative height.
            constraints: BoxConstraints(
              minHeight: math.max(0, constraints.maxHeight - bottomInset),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FractionallySizedBox(
                  widthFactor: _illustrationWidthFactor,
                  child: Image.asset(
                    Assets.emptyIllustration,
                    fit: BoxFit.contain,
                    semanticLabel: TranslationKeys.documentsEmptyTitle.tr(),
                  ),
                ),
                const SizedBox(height: _illustrationToTitleGap),
                Text(
                  TranslationKeys.documentsEmptyTitle.tr(),
                  style: AppTypography.titleL.copyWith(
                    color: AppColors.textOnGlass,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ContentSheet.horizontalInset,
                  ),
                  child: Text(
                    TranslationKeys.documentsEmptySubtitle.tr(),
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: SourcePill.gap,
                    runSpacing: SourcePill.gap,
                    children: <Widget>[
                      for (final DocumentSource source in DocumentSource.values)
                        SourcePill(
                          source: source,
                          style: SourcePillStyle.onEmptyState,
                          onTap: () => onSourceSelected(source),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
