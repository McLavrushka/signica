import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signica/features/documents/presentation/widgets/bottom_bar_shell.dart';

/// `reservedHeight` is what the scrolling content keeps free under itself, and
/// the shell is what actually gets drawn there. They are two expressions of one
/// number, written in two places, so they can drift — they did, by a whole gap.
/// This pins them together without a simulator.
/// Marks the bar itself, as opposed to the shell around it: the shell spans
/// the safe area too, so its own rect always ends at the bottom of the screen.
const Key _barKey = Key('bar');

void main() {
  Future<Rect> pumpShell(
    WidgetTester tester, {
    required double height,
    required double safeAreaBottom,
  }) async {
    late double reserved;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(
            padding: EdgeInsets.only(bottom: safeAreaBottom),
          ),
          child: Builder(
            builder: (BuildContext context) {
              reserved = BottomBarMetrics.reservedHeight(context);
              return Align(
                alignment: Alignment.bottomCenter,
                child: BottomBarShell(
                  height: height,
                  child: const SizedBox.expand(key: _barKey),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    _reserved = reserved;
    return tester.getRect(find.byType(BottomBarShell));
  }

  for (final double inset in <double>[0, 34]) {
    testWidgets('the bar reserves exactly what it covers, inset $inset', (
      WidgetTester tester,
    ) async {
      final Rect rect = await pumpShell(
        tester,
        height: BottomBarMetrics.barHeight,
        safeAreaBottom: inset,
      );

      expect(rect.height, moreOrLessEquals(_reserved, epsilon: 0.01));
    });
  }

  testWidgets('the search state reserves less, by the height it drops', (
    WidgetTester tester,
  ) async {
    expect(
      BottomBarMetrics.barHeight - BottomBarMetrics.compactBarHeight,
      greaterThan(0),
    );

    final Rect compact = await pumpShell(
      tester,
      height: BottomBarMetrics.compactBarHeight,
      safeAreaBottom: 34,
    );

    expect(
      compact.height,
      moreOrLessEquals(
        _reserved -
            (BottomBarMetrics.barHeight - BottomBarMetrics.compactBarHeight),
        epsilon: 0.01,
      ),
    );
  });

  testWidgets('the bar clears the home indicator', (WidgetTester tester) async {
    const double inset = 34;
    await pumpShell(
      tester,
      height: BottomBarMetrics.barHeight,
      safeAreaBottom: inset,
    );
    final Rect rect = tester.getRect(find.byKey(_barKey));
    final Size screen = tester.view.physicalSize / tester.view.devicePixelRatio;

    expect(
      screen.height - rect.bottom,
      moreOrLessEquals(inset + BottomBarMetrics.gap, epsilon: 0.01),
    );
  });
}

/// Captured inside the pump so the assertion reads the same value the widget
/// tree was built with.
late double _reserved;
