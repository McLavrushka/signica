import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:signica/app/assets.dart';
import 'package:signica/app/l10n/translation_keys.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_motion.dart';
import 'package:signica/app/theme/app_spacing.dart';
import 'package:signica/app/theme/app_typography.dart';
import 'package:signica/app/widgets/app_icon.dart';
import 'package:signica/app/widgets/app_tappable.dart';
import 'package:signica/features/documents/presentation/widgets/anchored_menu.dart';
import 'package:signica/features/documents/presentation/widgets/documents_menu.dart';

const double _quickActionsHeight = 56;
const double _quickActionsInset = 10;
const double _tileGap = 6;

/// The delete row lines up with the separator above it.
const double _iconColumnInset = MenuDivider.inset;

/// Quick-action glyph sizes off the mock-up render: the printer is a wide
/// shape drawn at Regular, the share arrow a tall one drawn at Semibold.
const double _printerGlyph = 18;
const double _shareGlyph = 18.67;

/// Opens the actions menu anchored under [anchor], the rectangle of the card
/// the gesture started on.
Future<void> showDocumentActions(
  BuildContext context, {
  required Rect anchor,
  required VoidCallback onPrint,
  required VoidCallback onShare,
  required VoidCallback onDelete,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: CupertinoLocalizations.of(context).modalBarrierDismissLabel,
    // The design dims the other cards instead of laying a scrim over the whole
    // screen, so the barrier only has to catch the dismissing tap.
    barrierColor: AppColors.barrier,
    transitionDuration: AppMotion.fast,
    pageBuilder: (BuildContext dialogContext, _, _) => AnchoredMenu(
      anchor: anchor,
      // The menu is its own route, outside the Material of the screen, and
      // text with no Material above it falls back to the debug style.
      child: Material(
        type: MaterialType.transparency,
        child: DocumentActionsMenu(
          onPrint: () {
            Navigator.of(dialogContext).pop();
            onPrint();
          },
          onShare: () {
            Navigator.of(dialogContext).pop();
            onShare();
          },
          onDelete: () {
            Navigator.of(dialogContext).pop();
            onDelete();
          },
        ),
      ),
    ),
    transitionBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          _,
          Widget child,
        ) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            alignment: Alignment.topCenter,
            scale: Tween<double>(begin: AppMotion.appearScale, end: 1).animate(
              CurvedAnimation(parent: animation, curve: AppMotion.emphasized),
            ),
            child: child,
          ),
        ),
  );
}

/// Long-press menu over a single document: Print and Share side by side, then
/// Delete under a separator.
class DocumentActionsMenu extends StatelessWidget {
  const DocumentActionsMenu({
    required this.onPrint,
    required this.onShare,
    required this.onDelete,
    super.key,
  });

  /// Width of the panel, which the screen needs to place it under a card.
  static const double width = 250;

  final VoidCallback onPrint;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassMenuSurface(
      width: width,
      children: <Widget>[
        SizedBox(
          height: _quickActionsHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _quickActionsInset),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _ActionTile(
                    icon: AppIcons.printerFill,
                    iconSize: _printerGlyph,
                    label: TranslationKeys.actionPrint.tr(),
                    onTap: onPrint,
                  ),
                ),
                const SizedBox(width: _tileGap),
                Expanded(
                  child: _ActionTile(
                    icon: AppIcons.shareSemibold,
                    iconSize: _shareGlyph,
                    label: TranslationKeys.actionShare.tr(),
                    onTap: onShare,
                  ),
                ),
              ],
            ),
          ),
        ),
        const MenuDivider(),
        MenuRow(
          icon: AppIcons.trashRegular,
          label: TranslationKeys.actionDelete.tr(),
          onTap: onDelete,
          horizontalInset: _iconColumnInset,
          isDestructive: true,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconSize,
    required this.label,
    required this.onTap,
  });

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.s4,
    vertical: 6,
  );

  /// Glyph asset from `AppIcons`.
  final String icon;

  /// The two quick actions are drawn at different weights and shapes in the
  /// design, so each tile is told its own glyph size.
  final double iconSize;

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTappable(
      onTap: onTap,
      label: label,
      child: Padding(
        padding: _padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIcon(icon, size: iconSize, color: AppColors.menuForeground),
            const SizedBox(height: AppSpacing.s4),
            Text(
              label,
              style: AppTypography.labelS.copyWith(
                color: AppColors.menuForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
