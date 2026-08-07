import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Draws one glyph from [AppIcons] the way [Icon] draws one from a font: a
/// square slot, the colour coming from the icon theme unless it is overridden.
///
/// [size] is the slot, and because every asset's viewBox is the tight outline,
/// it is also the glyph's longer side — an ellipsis asked for at 18 draws 18
/// wide and about 4 tall, not 18 of mostly nothing. That is what makes the
/// numbers at the call sites the same numbers the mock-up measures.
class AppIcon extends StatelessWidget {
  const AppIcon(this.asset, {required this.size, this.color, super.key});

  final String asset;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color? resolved = color ?? IconTheme.of(context).color;

    // `Align` around the box, not a bare `SizedBox`. Under tight constraints —
    // which is what `AspectRatio` and `Positioned.fill` hand down — a `SizedBox`
    // enforces the incoming constraints over its own dimension, so [size] is
    // dropped and the glyph inflates to fill whatever it was put in. `Align`
    // takes the size it is given and centres the child at its own; the factors
    // collapse it back onto the glyph when the constraints are loose, which is
    // every other call site.
    return Align(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox.square(
        dimension: size,
        child: SvgPicture.asset(
          asset,
          fit: BoxFit.contain,
          colorFilter: resolved == null
              ? null
              : ColorFilter.mode(resolved, BlendMode.srcIn),
        ),
      ),
    );
  }
}
