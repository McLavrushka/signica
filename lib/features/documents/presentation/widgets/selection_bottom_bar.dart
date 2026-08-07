import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:signica/app/assets.dart';
import 'package:signica/app/l10n/translation_keys.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_glass.dart';
import 'package:signica/features/documents/presentation/widgets/bottom_bar_shell.dart';
import 'package:signica/features/documents/presentation/widgets/glass_circle_button.dart';

/// Glyph sizes off the mock-up render. The design draws both at Bold, and the
/// share arrow is the taller shape of the two.
const double _deleteGlyph = 22.67;
const double _shareGlyph = 23.33;

/// Bottom bar while selecting: delete on the left, share on the right. Both
/// buttons stay in place and go dim while nothing is picked.
class SelectionBottomBar extends StatelessWidget {
  const SelectionBottomBar({
    required this.hasSelection,
    required this.onDelete,
    required this.onShare,
    super.key,
  });

  final bool hasSelection;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return BottomBarShell(
      height: BottomBarMetrics.barHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GlassCircleButton(
            icon: AppIcons.trashBold,
            iconSize: _deleteGlyph,
            iconColor: AppColors.destructive,
            // The design draws these discs nearly opaque, unlike the lighter
            // glass of the idle bar.
            glass: AppGlass.sourceOnOverlay,
            isEnabled: hasSelection,
            semanticsLabel: TranslationKeys.actionDelete.tr(),
            onTap: onDelete,
          ),
          GlassCircleButton(
            icon: AppIcons.shareBold,
            iconSize: _shareGlyph,
            glass: AppGlass.sourceOnOverlay,
            isEnabled: hasSelection,
            semanticsLabel: TranslationKeys.actionShare.tr(),
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}
