import 'package:flutter/widgets.dart';
import 'package:signica/app/theme/app_motion.dart';
import 'package:signica/app/theme/app_spacing.dart';

/// Metrics of the floating bottom bar; single source so the space reserved
/// under the grid always matches what the bar actually draws.
abstract final class BottomBarMetrics {
  /// The bar's own height. An iOS circular control is 62pt across; everything
  /// else in the row is as tall as the row, not sized on its own.
  static const double barHeight = 62;

  /// Search state: the field and its close button drop to the compact iOS
  /// control height.
  static const double compactBarHeight = 48;

  /// Gap between the bar and the bottom safe area in the design.
  static const double gap = 12;

  static const Duration morphDuration = AppMotion.slow;
  static const Curve morphCurve = AppMotion.standard;

  /// Space the bar covers, which scrolling content has to clear. Derived from
  /// what the bar renders, so the two cannot disagree.
  static double reservedHeight(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + gap + barHeight;
}

/// The shell both bottom bars sit in: safe area, side padding, and the gap that
/// rides the keyboard. Owns the bar's height so its children can simply stretch
/// into it.
class BottomBarShell extends StatelessWidget {
  const BottomBarShell({
    required this.height,
    required this.child,
    this.horizontalPadding = AppSpacing.s12,
    super.key,
  });

  final double height;
  final Widget child;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: BottomBarMetrics.morphDuration,
        curve: BottomBarMetrics.morphCurve,
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          bottom:
              MediaQuery.viewInsetsOf(context).bottom + BottomBarMetrics.gap,
        ),
        child: AnimatedContainer(
          duration: BottomBarMetrics.morphDuration,
          curve: BottomBarMetrics.morphCurve,
          height: height,
          child: child,
        ),
      ),
    );
  }
}
