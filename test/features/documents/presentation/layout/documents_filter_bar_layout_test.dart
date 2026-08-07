import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/features/documents/domain/entities/documents_filter.dart';
import 'package:signica/features/documents/presentation/widgets/documents_filter_bar.dart';

/// The thumb is placed by `Alignment(-1 + 2 * index / (count - 1), 0)` and
/// sized by `maxWidth / count` — two different denominators, which is the kind
/// of arithmetic that is right until someone "fixes" it. These tests say what
/// it has to produce instead of restating the formula.
void main() {
  Future<void> pumpBar(
    WidgetTester tester,
    DocumentsFilter filter, {
    double width = 375,
  }) async {
    tester.view
      ..physicalSize = Size(width, 200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(),
          child: Align(
            alignment: Alignment.topCenter,
            child: DocumentsFilterBar(filter: filter, onChanged: (_) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The thumb is the first `Container` inside the track after the track
  /// itself, and the labels sit in the `Row` beside it.
  Rect thumbRect(WidgetTester tester) {
    final Finder thumb = find
        .descendant(
          of: find.byType(DocumentsFilterBar),
          matching: find.byType(Container),
        )
        .at(1);
    return tester.getRect(thumb);
  }

  Rect labelRect(WidgetTester tester, DocumentsFilter filter) => tester.getRect(
    find
        .descendant(
          of: find.byType(DocumentsFilterBar),
          matching: find.byType(Text),
        )
        .at(DocumentsFilter.values.indexOf(filter)),
  );

  for (final DocumentsFilter filter in DocumentsFilter.values) {
    testWidgets('the thumb centres on the ${filter.name} segment', (
      WidgetTester tester,
    ) async {
      await pumpBar(tester, filter);

      expect(
        thumbRect(tester).center.dx,
        moreOrLessEquals(labelRect(tester, filter).center.dx, epsilon: 0.01),
      );
    });
  }

  testWidgets('the thumb is one segment wide', (WidgetTester tester) async {
    await pumpBar(tester, DocumentsFilter.all);

    final double thumbWidth = thumbRect(tester).width;
    final double first = labelRect(tester, DocumentsFilter.all).center.dx;
    final double second = labelRect(tester, DocumentsFilter.signed).center.dx;

    // Segment centres are one segment apart, so the step is the width.
    expect(thumbWidth, moreOrLessEquals(second - first, epsilon: 0.01));
  });

  testWidgets('the thumb never leaves the track at either end', (
    WidgetTester tester,
  ) async {
    await pumpBar(tester, DocumentsFilter.all);
    final Rect bar = tester.getRect(find.byType(DocumentsFilterBar));
    expect(thumbRect(tester).left, greaterThanOrEqualTo(bar.left));

    await pumpBar(tester, DocumentsFilter.unsigned);
    expect(thumbRect(tester).right, lessThanOrEqualTo(bar.right));
  });

  /// The thumb says which segment is selected; so does the label colour, and
  /// the two have to agree. The design draws the unselected pair at 40% of the
  /// same ink in every frame that shows a real list.
  testWidgets('only the selected label is at full strength', (
    WidgetTester tester,
  ) async {
    for (final DocumentsFilter filter in DocumentsFilter.values) {
      await pumpBar(tester, filter);

      for (final DocumentsFilter value in DocumentsFilter.values) {
        final Text label = tester.widget<Text>(
          find
              .descendant(
                of: find.byType(DocumentsFilterBar),
                matching: find.byType(Text),
              )
              .at(DocumentsFilter.values.indexOf(value)),
        );

        expect(
          label.style?.color,
          value == filter
              ? AppColors.textPrimary
              : AppColors.textSegmentInactive,
          reason: '${value.name} while ${filter.name} is selected',
        );
      }
    }
  });

  testWidgets('the geometry holds at a width the design never drew', (
    WidgetTester tester,
  ) async {
    await pumpBar(tester, DocumentsFilter.signed, width: 320);

    expect(
      thumbRect(tester).center.dx,
      moreOrLessEquals(
        labelRect(tester, DocumentsFilter.signed).center.dx,
        epsilon: 0.01,
      ),
    );
  });
}
