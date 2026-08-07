import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// How close a menu may come to the edge of the screen, and how far it rides up
/// over the card it belongs to.
const double _screenMargin = 22;
const double _anchorOverlap = 9;

/// Places a context menu under the card it was opened from, the way iOS does:
/// centred on the card, kept inside the screen, and flipped above the card when
/// there is no room below it.
class AnchoredMenu extends StatelessWidget {
  const AnchoredMenu({required this.anchor, required this.child, super.key});

  /// The card, in global coordinates.
  final Rect anchor;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _AnchoredMenuLayout(
        anchor: anchor,
        safeArea: MediaQuery.paddingOf(context),
      ),
      child: child,
    );
  }
}

class _AnchoredMenuLayout extends SingleChildLayoutDelegate {
  const _AnchoredMenuLayout({required this.anchor, required this.safeArea});

  final Rect anchor;
  final EdgeInsets safeArea;

  /// The panel states a preferred width, but it may not outgrow the screen it
  /// has to stay inside — on a narrow device it shrinks rather than overflows.
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen().copyWith(
        maxWidth: math.max(0, constraints.maxWidth - _screenMargin * 2),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double rightmost = math.max(
      _screenMargin,
      size.width - childSize.width - _screenMargin,
    );
    final double left = (anchor.center.dx - childSize.width / 2).clamp(
      _screenMargin,
      rightmost,
    );

    final double below = anchor.bottom - _anchorOverlap;
    final double lowest =
        size.height - safeArea.bottom - _screenMargin - childSize.height;
    final double top = below <= lowest
        ? below
        : math.max(
            safeArea.top + _screenMargin,
            anchor.top + _anchorOverlap - childSize.height,
          );

    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_AnchoredMenuLayout oldDelegate) =>
      anchor != oldDelegate.anchor || safeArea != oldDelegate.safeArea;
}
