import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:signica/app/assets.dart';
import 'package:signica/app/l10n/translation_keys.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_glass.dart';
import 'package:signica/app/theme/app_radius.dart';
import 'package:signica/app/theme/app_spacing.dart';
import 'package:signica/app/theme/app_typography.dart';
import 'package:signica/app/widgets/app_tappable.dart';
import 'package:signica/features/documents/domain/entities/document_source.dart';

const double _height = 56;

const double _paddingH = 20;
const double _iconSize = 24;

/// Where a glass source pill is used — the two places differ in fill, label
/// colour and minimum width.
enum SourcePillStyle {
  /// Empty state: the pill is as wide as its content.
  onEmptyState,

  /// Add-document overlay: the pills line up, so they share a minimum width.
  onOverlay,
}

/// Files / Photos / Scanner pill.
///
/// Width follows the label — a longer translation makes the pill wider instead
/// of clipping it.
class SourcePill extends StatelessWidget {
  const SourcePill({
    required this.source,
    required this.style,
    required this.onTap,
    super.key,
  });

  /// Gap between pills, both on the empty state and in the overlay.
  static const double gap = AppSpacing.s12;

  /// Width the overlay pills line up to.
  static const double overlayMinWidth = 128;

  final DocumentSource source;
  final SourcePillStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool onOverlay = style == SourcePillStyle.onOverlay;

    return AppTappable(
      onTap: onTap,
      label: _label.tr(),
      child: IntrinsicWidth(
        // No hand-drawn rim here, unlike `GlassPanel`. An opaque border sits
        // exactly where the premium shader puts its specular highlight and
        // paints over it, and the pill goes back to reading as an outline.
        // The edge is the shader's.
        child: GlassContainer(
          height: _height,
          padding: const EdgeInsets.symmetric(horizontal: _paddingH),
          useOwnLayer: true,
          quality: AppGlass.quality,
          shape: const LiquidRoundedSuperellipse(borderRadius: AppRadius.pill),
          settings: onOverlay
              ? AppGlass.sourceOnOverlay
              : AppGlass.sourceOnSurface,
          // Centres the content when the stack forces the pill wider than its
          // label. The Row itself hugs, so it has no free space to align in.
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.icon),
                child: Image.asset(_icon, width: _iconSize, height: _iconSize),
              ),
              const SizedBox(width: AppSpacing.s8),
              Flexible(
                child: Text(
                  _label.tr(),
                  style: AppTypography.labelL.copyWith(
                    color: onOverlay
                        ? AppColors.textPrimary
                        : AppColors.textSourceLabel,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _icon => switch (source) {
    DocumentSource.files => Assets.sourceFiles,
    DocumentSource.photos => Assets.sourcePhotos,
    DocumentSource.scanner => Assets.sourceScanner,
  };

  String get _label => switch (source) {
    DocumentSource.files => TranslationKeys.sourceFiles,
    DocumentSource.photos => TranslationKeys.sourcePhotos,
    DocumentSource.scanner => TranslationKeys.sourceScanner,
  };
}
