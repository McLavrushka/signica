import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/widgets/app_icon.dart';
import 'package:signica/app/widgets/app_tappable.dart';
import 'package:signica/app/widgets/glass_surfaces.dart';

/// Round glass button of the bottom bar (search, delete, share).
///
/// Takes its diameter from the height the bar gives it rather than carrying a
/// size of its own — the bar is what knows how tall it is right now.
class GlassCircleButton extends StatelessWidget {
  const GlassCircleButton({
    required this.icon,
    required this.iconSize,
    required this.onTap,
    this.iconColor = AppColors.textOnGlass,
    this.glass,
    this.isEnabled = true,
    this.semanticsLabel,
    super.key,
  });

  /// Glyph asset from `AppIcons`.
  final String icon;

  /// Size of the glyph, not of the button: the design draws a different one
  /// per action, and the button's own diameter comes from the bar.
  final double iconSize;

  final VoidCallback onTap;
  final Color iconColor;

  /// Overrides the control glass where the design asks for a more opaque disc.
  final LiquidGlassSettings? glass;

  /// Disabled buttons in select mode are drawn dimmed.
  final bool isEnabled;

  /// Spoken name of the button; an icon alone tells VoiceOver nothing.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return AppTappable(
      onTap: onTap,
      isEnabled: isEnabled,
      label: semanticsLabel,
      child: GlassCircle(
        settings: glass,
        child: AppIcon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
