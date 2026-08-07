import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:signica/app/l10n/translation_keys.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_motion.dart';
import 'package:signica/app/theme/app_radius.dart';
import 'package:signica/app/theme/app_shadow.dart';
import 'package:signica/app/theme/app_spacing.dart';
import 'package:signica/app/theme/app_typography.dart';
import 'package:signica/app/widgets/app_tappable.dart';
import 'package:signica/features/documents/domain/entities/documents_filter.dart';

const double _trackHeight = 36;
const double _trackPaddingH = 8;
const double _trackPaddingV = 4;
const double _thumbHeight = 28;

/// Segmented control: All / Signed / Unsigned. The white thumb slides between
/// positions instead of being rebuilt, so the switch reads as one control.
class DocumentsFilterBar extends StatelessWidget {
  const DocumentsFilterBar({
    required this.filter,
    required this.onChanged,
    super.key,
  });

  /// Side margin of the track (`x=16` on the design frame).
  static const double horizontalMargin = AppSpacing.s16;

  static const List<DocumentsFilter> _filters = DocumentsFilter.values;

  final DocumentsFilter filter;
  final ValueChanged<DocumentsFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Container(
        height: _trackHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: _trackPaddingH,
          vertical: _trackPaddingV,
        ),
        decoration: BoxDecoration(
          color: AppColors.segmentedTrack,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double segmentWidth = constraints.maxWidth / _filters.length;
            final int index = _filters.indexOf(filter);

            return Stack(
              children: <Widget>[
                AnimatedAlign(
                  // -1 … 1 across the track, whatever the segment count is.
                  alignment: Alignment(
                    -1 + 2 * index / (_filters.length - 1),
                    0,
                  ),
                  duration: AppMotion.medium,
                  curve: AppMotion.standard,
                  child: Container(
                    width: segmentWidth,
                    height: _thumbHeight,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      boxShadow: AppShadow.control,
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    for (final DocumentsFilter value in _filters)
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: <Widget>[
                            // Separators live between segments and fade out
                            // next to the thumb, as in the design.
                            if (value != _filters.first)
                              _Separator(
                                isVisible: !_touchesThumb(value, index),
                              ),
                            AppTappable(
                              selected: value == filter,
                              onTap: () => onChanged(value),
                              child: SizedBox(
                                height: _thumbHeight,
                                child: Center(
                                  child: Text(
                                    _label(value).tr(),
                                    // Only the selected segment is at full
                                    // strength; the others are the same colour
                                    // at 40%, which is what tells them apart
                                    // once the thumb has slid away.
                                    style: AppTypography.labelM.copyWith(
                                      color: value == filter
                                          ? AppColors.textPrimary
                                          : AppColors.textSegmentInactive,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _touchesThumb(DocumentsFilter value, int selectedIndex) {
    final int index = _filters.indexOf(value);
    return index == selectedIndex || index == selectedIndex + 1;
  }

  String _label(DocumentsFilter value) => switch (value) {
    DocumentsFilter.all => TranslationKeys.filterAll,
    DocumentsFilter.signed => TranslationKeys.filterSigned,
    DocumentsFilter.unsigned => TranslationKeys.filterUnsigned,
  };
}

class _Separator extends StatelessWidget {
  const _Separator({required this.isVisible});

  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    // The 30% the design asks for is already baked into the colour, so this
    // only switches the separator on and off — multiplying again would land it
    // at 9%.
    return AnimatedOpacity(
      opacity: isVisible ? 1 : 0,
      duration: AppMotion.fast,
      child: const SizedBox(
        width: 1,
        height: _thumbHeight,
        child: ColoredBox(color: AppColors.segmentedSeparator),
      ),
    );
  }
}
