import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:signica/app/assets.dart';
import 'package:signica/app/l10n/translation_keys.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_radius.dart';
import 'package:signica/app/theme/app_spacing.dart';
import 'package:signica/app/theme/app_typography.dart';
import 'package:signica/app/widgets/app_icon.dart';
import 'package:signica/app/widgets/app_tappable.dart';

const double _logoToTitleGap = 10;

/// Dark header row: logo, app name, "…" button.
///
/// The mock-up puts the row under a 47pt status bar; [topGap] is measured from
/// the real safe area instead, so the notch and the Dynamic Island both work.
class DocumentsHeader extends StatelessWidget {
  const DocumentsHeader({required this.onMenuTap, super.key});

  static const double horizontalPadding = 18;

  /// Distance from the safe area to the row.
  static const double topGap = 12;

  /// Square tiles in the header — the logo and the "…" button.
  static const double tileSize = 38;

  /// Glyph sizes, each measured off the mock-up render rather than picked:
  /// the "…" is a wide, short shape and the close cross is square, so one
  /// shared number would draw one of them wrong.
  static const double _ellipsisSize = 18;
  static const double _closeSize = 15.67;

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox.square(
          dimension: tileSize,
          // Clip on the outside, fill on the inside: the radius is stated once
          // rather than repeated on a DecoratedBox and the ClipRRect inside it.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.tile),
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: AppColors.accent),
              child: SvgPicture.asset(Assets.logo, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(width: _logoToTitleGap),
        Expanded(
          child: Text(
            TranslationKeys.appTitle.tr(),
            style: AppTypography.titleM.copyWith(color: AppColors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        HeaderTile(
          label: TranslationKeys.actionSelect.tr(),
          onTap: onMenuTap,
          child: const AppIcon(
            AppIcons.ellipsis,
            size: DocumentsHeader._ellipsisSize,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

/// The same bar while selecting: the select-all action on the left, the close
/// button on the right. There is no separate counter; the count lives in the
/// "Deselect All (n)" label.
class DocumentsSelectionHeader extends StatelessWidget {
  const DocumentsSelectionHeader({
    required this.selectedCount,
    required this.onToggleSelectAll,
    required this.onClose,
    super.key,
  });

  static const double horizontalPadding = 16;

  final int selectedCount;
  final VoidCallback onToggleSelectAll;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selectedCount > 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: _SelectAllPill(
            label: hasSelection
                ? TranslationKeys.actionDeselectAll.tr(
                    namedArgs: <String, String>{'count': '$selectedCount'},
                  )
                : TranslationKeys.actionSelectAll.tr(),
            onTap: onToggleSelectAll,
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        HeaderTile(
          label: CupertinoLocalizations.of(context).modalBarrierDismissLabel,
          onTap: onClose,
          child: const AppIcon(
            AppIcons.closeSemibold,
            size: DocumentsHeader._closeSize,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

/// Select-all action: a pill on the same translucent fill as the header tiles.
class _SelectAllPill extends StatelessWidget {
  const _SelectAllPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTappable(
      onTap: onTap,
      label: label,
      child: SizedBox(
        height: DocumentsHeader.tileSize,
        child: _HeaderSurface(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
            // `widthFactor: 1` keeps the pill hugging its label instead of
            // taking the whole row.
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: AppTypography.labelM.copyWith(color: AppColors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Square translucent button in the header.
class HeaderTile extends StatelessWidget {
  const HeaderTile({
    required this.child,
    required this.label,
    required this.onTap,
    super.key,
  });

  final Widget child;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTappable(
      onTap: onTap,
      label: label,
      child: SizedBox.square(
        dimension: DocumentsHeader.tileSize,
        child: _HeaderSurface(child: Center(child: child)),
      ),
    );
  }
}

/// The surface shared by everything sitting on the dark header: tiles and the
/// select-all pill are the same surface at two widths.
///
/// Deliberately not a `GlassContainer`: the header is flat colour with
/// nothing behind these controls to refract, and the shader's own edge
/// measured wrong against the mock-up (see `AppGlass`). A fill plus a light
/// edge reproduces the look directly.
class _HeaderSurface extends StatelessWidget {
  const _HeaderSurface({required this.child});

  /// Rim colour tuned so the composited edge over the fill matches the
  /// mock-up's measured 92 (17% over the fill, not 25% — see history).
  static const Color _rim = Color(0x2CFFFFFF);
  static const double _rimWidth = 1;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.headerControl,
        border: Border.all(color: _rim, width: _rimWidth),
        borderRadius: BorderRadius.circular(AppRadius.tile),
      ),
      child: child,
    );
  }
}
