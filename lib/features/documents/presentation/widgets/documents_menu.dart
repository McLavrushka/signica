import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:signica/app/assets.dart';
import 'package:signica/app/l10n/translation_keys.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_spacing.dart';
import 'package:signica/app/theme/app_typography.dart';
import 'package:signica/app/widgets/app_icon.dart';
import 'package:signica/app/widgets/app_tappable.dart';
import 'package:signica/app/widgets/glass_surfaces.dart';

/// Glass panel both context menus are built on. The two differ in width, so it
/// is a parameter and not a constant of the panel.
class GlassMenuSurface extends StatelessWidget {
  const GlassMenuSurface({
    required this.children,
    required this.width,
    super.key,
  });

  static const double itemHeight = 40;
  static const double iconColumnWidth = 28;
  static const double verticalPadding = 10;

  /// Glyph size shared by every row of every menu: rows are one component in
  /// the design, drawn at one size, so this is the menu's number and not each
  /// row's own.
  static const double rowGlyphSize = 17.33;

  final List<Widget> children;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: verticalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // Rows and the separator span the panel; without this they collapse
        // to the width of their own content.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Glass menu opened from the "…" button in the header.
class DocumentsMenu extends StatelessWidget {
  const DocumentsMenu({
    required this.onSelect,
    required this.onAddDocument,
    super.key,
  });

  static const double width = 262;

  /// Icon column of the wide header menu.
  static const double _iconColumnInset = 40;

  final VoidCallback onSelect;
  final VoidCallback onAddDocument;

  @override
  Widget build(BuildContext context) {
    return GlassMenuSurface(
      width: width,
      children: <Widget>[
        MenuRow(
          icon: AppIcons.checkmarkCircle,
          label: TranslationKeys.actionSelect.tr(),
          onTap: onSelect,
          horizontalInset: _iconColumnInset,
        ),
        MenuRow(
          icon: AppIcons.addRegular,
          label: TranslationKeys.actionAddDocument.tr(),
          onTap: onAddDocument,
          horizontalInset: _iconColumnInset,
        ),
      ],
    );
  }
}

/// One row of a glass menu.
class MenuRow extends StatelessWidget {
  const MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.horizontalInset,
    this.isDestructive = false,
    super.key,
  });

  /// Glyph asset from `AppIcons`.
  final String icon;
  final String label;
  final VoidCallback onTap;

  /// Distance from the edge of the panel to the icon column, which differs
  /// between the two menu widths in the design.
  final double horizontalInset;

  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color color = isDestructive
        ? AppColors.destructive
        : AppColors.menuForeground;

    return AppTappable(
      onTap: onTap,
      label: label,
      child: SizedBox(
        height: GlassMenuSurface.itemHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalInset),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: GlassMenuSurface.iconColumnWidth,
                child: AppIcon(
                  icon,
                  size: GlassMenuSurface.rowGlyphSize,
                  color: color,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.bodyL.copyWith(color: color),
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
}

/// Hairline between two blocks of a glass menu.
class MenuDivider extends StatelessWidget {
  const MenuDivider({super.key});

  static const double inset = AppSpacing.s24;
  static const double _gap = GlassMenuSurface.verticalPadding;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(inset, _gap, inset, _gap),
      child: SizedBox(
        height: 1,
        child: ColoredBox(color: AppColors.menuDivider),
      ),
    );
  }
}
