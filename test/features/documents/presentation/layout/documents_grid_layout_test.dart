import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/presentation/widgets/document_card.dart';
import 'package:signica/features/documents/presentation/widgets/documents_grid.dart';

/// The integration suite pins the grid to the design frame. This one pins the
/// *rule* the frame is one instance of, at widths the design never drew, and it
/// runs without a device.
void main() {
  List<Document> documents(int count) => <Document>[
    for (int i = 0; i < count; i++)
      Document(
        id: '$i',
        name: 'Document $i',
        filePath: '/tmp/$i.pdf',
        firstPagePreviewPath: '/tmp/$i-first.png',
        pageCount: 1,
        createdAt: DateTime(2025, 4, 12),
      ),
  ];

  Future<List<double>> cardWidths(WidgetTester tester, double width) async {
    tester.view
      ..physicalSize = Size(width, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(),
          child: DocumentsGrid(documents: documents(8), onDocumentTap: (_) {}),
        ),
      ),
    );

    final Finder cards = find.byType(DocumentCard);
    return <double>[
      for (int i = 0; i < tester.widgetList(cards).length; i++)
        tester.getSize(cards.at(i)).width,
    ];
  }

  /// The one rule the grid promises: a card is never narrower than the width
  /// the column count is chosen from. Everything else about the grid follows.
  testWidgets('a card is never narrower than the preferred width', (
    WidgetTester tester,
  ) async {
    for (final double width in <double>[375, 390, 430, 744, 812, 1024]) {
      final List<double> widths = await cardWidths(tester, width);
      expect(
        widths.first,
        greaterThanOrEqualTo(DocumentsGrid.preferredItemWidth),
        reason: 'card too narrow at ${width}pt',
      );
    }
  });

  testWidgets('every card in a row is the same width', (
    WidgetTester tester,
  ) async {
    final List<double> widths = await cardWidths(tester, 430);

    expect(widths, everyElement(moreOrLessEquals(widths.first, epsilon: 0.01)));
  });

  /// Counts the cards sharing the top edge of the first row.
  int columnsInFirstRow(WidgetTester tester) {
    final Finder cards = find.byType(DocumentCard);
    final double top = tester.getTopLeft(cards.first).dy;
    return <int>[
      for (int i = 0; i < tester.widgetList(cards).length; i++)
        if (tester.getTopLeft(cards.at(i)).dy == top) i,
    ].length;
  }

  testWidgets('a row fills the sheet edge to edge', (
    WidgetTester tester,
  ) async {
    // The gap the grid puts between columns. Stated here rather than imported
    // so the test fails if the grid silently changes it.
    const double gap = 19;

    for (final double width in <double>[320, 375, 430, 812]) {
      final List<double> widths = await cardWidths(tester, width);
      final int columns = columnsInFirstRow(tester);
      final double content = width - DocumentsGrid.horizontalPadding * 2;

      expect(
        widths.first * columns + gap * (columns - 1),
        moreOrLessEquals(content, epsilon: 0.01),
        reason: 'the row leaves an unexplained gap at ${width}pt',
      );
    }
  });

  /// A one-up grid is a list. The floor is the only case where a card is
  /// allowed to come out narrower than preferred, and this pins the price.
  testWidgets('a narrow phone still gets two columns', (
    WidgetTester tester,
  ) async {
    final List<double> widths = await cardWidths(tester, 320);

    expect(widths.first, moreOrLessEquals(122.5, epsilon: 0.01));
  });

  /// There is no column ceiling: extra width buys columns, not wider cards.
  testWidgets('a wide canvas adds columns instead of stretching cards', (
    WidgetTester tester,
  ) async {
    final List<double> narrow = await cardWidths(tester, 375);
    final List<double> wide = await cardWidths(tester, 1024);

    expect(wide.first, lessThan(narrow.first * 2));
    expect(wide.first, greaterThanOrEqualTo(DocumentsGrid.preferredItemWidth));
  });
}
