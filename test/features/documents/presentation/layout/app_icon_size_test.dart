import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signica/app/assets.dart';
import 'package:signica/app/widgets/app_icon.dart';

/// A glyph is drawn at the size the call site asks for, whatever box it is put
/// in. The interesting case is a *tight* box: `AspectRatio`, `Positioned.fill`
/// and `SizedBox.expand` all lay their child out under tight constraints, and a
/// widget that sizes itself with a plain `SizedBox` silently loses its size
/// there. That is not hypothetical — the bottom bar's close button drew a
/// 16.67pt cross at 62pt for exactly this reason.
void main() {
  const double glyph = 16.67;
  const double box = 62;

  Future<Size> pumpIn(WidgetTester tester, Widget Function(Widget) wrap) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox.square(
            dimension: box,
            child: wrap(const AppIcon(AppIcons.closeMedium, size: glyph)),
          ),
        ),
      ),
    );
    // The picture is what actually gets painted, so it is what the
    // assertion has to measure — not the box the call site asked for.
    return tester.getSize(find.byType(SvgPicture));
  }

  testWidgets('a glyph keeps its size inside an AspectRatio', (
    WidgetTester tester,
  ) async {
    final Size size = await pumpIn(
      tester,
      (Widget child) => AspectRatio(aspectRatio: 1, child: child),
    );

    expect(size.width, moreOrLessEquals(glyph, epsilon: 0.01));
    expect(size.height, moreOrLessEquals(glyph, epsilon: 0.01));
  });

  testWidgets('a glyph keeps its size inside a tight box', (
    WidgetTester tester,
  ) async {
    final Size size = await pumpIn(
      tester,
      (Widget child) => SizedBox.expand(child: child),
    );

    expect(size.width, moreOrLessEquals(glyph, epsilon: 0.01));
  });

  testWidgets('a glyph still hugs its size when the box is loose', (
    WidgetTester tester,
  ) async {
    final Size size = await pumpIn(
      tester,
      (Widget child) => Align(child: child),
    );

    expect(size.width, moreOrLessEquals(glyph, epsilon: 0.01));
  });
}
