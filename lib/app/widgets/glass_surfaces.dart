import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:signica/app/theme/app_glass.dart';
import 'package:signica/app/theme/app_radius.dart';
import 'package:signica/app/theme/app_shadow.dart';

/// The three glass shapes the design uses, so a shape and the settings that
/// belong to it are chosen once instead of at every call site.
///
/// All three ask for their own layer. That is not a performance knob: a glass
/// surface without one renders grouped, which means it takes its settings from
/// an ancestor `LiquidGlassLayer` and ignores its own. These surfaces each have
/// their own material, and there is no ancestor layer to inherit from.

/// Pill-shaped control: the search field, the primary action.
class GlassPill extends StatelessWidget {
  const GlassPill({
    required this.child,
    this.height,
    this.padding,
    this.clipBehavior = Clip.none,
    super.key,
  });

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: height,
      padding: padding,
      clipBehavior: clipBehavior,
      useOwnLayer: true,
      quality: AppGlass.quality,
      shape: const LiquidRoundedSuperellipse(borderRadius: AppRadius.pill),
      settings: AppGlass.control,
      child: child,
    );
  }
}

/// Round control. Square by construction — an [AspectRatio] rather than two
/// equal numbers, so it stays round at whatever height the bar gives it.
class GlassCircle extends StatelessWidget {
  const GlassCircle({required this.child, this.settings, super.key});

  final Widget child;

  /// Overridden where the design asks for a more opaque disc than a plain
  /// control, as in the selection bar.
  final LiquidGlassSettings? settings;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GlassContainer(
        useOwnLayer: true,
        quality: AppGlass.quality,
        shape: const LiquidOval(),
        settings: settings ?? AppGlass.control,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

/// Floating menu panel: the glass and the shadow it casts belong together, so
/// one widget owns both and they cannot drift apart.
///
/// The shadow is a plain rounded rectangle while the panel is a superellipse.
/// The two outlines part by a couple of points on the corner diagonal, which at
/// this blur and alpha is not observable; drawing the superellipse path would
/// mean a [CustomPainter] for nothing.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    required this.width,
    this.padding,
    super.key,
  });

  /// Bright edge the design runs around the panel. Nearly opaque white, unlike
  /// the faint rim of a control on the dark header — the two surfaces sit on
  /// opposite backgrounds, so one shared value would be wrong for both.
  static const Color _rim = Color(0xE6FFFFFF);
  static const double _rimWidth = 1;

  final Widget child;
  final double width;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    // Three layers, outside in: the shadow it casts, the glass itself, and the
    // rim drawn on top of the glass rather than under it.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.menu),
        boxShadow: AppShadow.menu,
      ),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border.all(color: _rim, width: _rimWidth),
          borderRadius: BorderRadius.circular(AppRadius.menu),
        ),
        // A tight width rather than a fixed one: the panel asks for its design
        // width and takes less when the viewport cannot give it that.
        child: GlassContainer(
          width: width,
          padding: padding,
          useOwnLayer: true,
          quality: AppGlass.quality,
          shape: const LiquidRoundedSuperellipse(borderRadius: AppRadius.menu),
          settings: AppGlass.menu,
          child: child,
        ),
      ),
    );
  }
}
