import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoAlertDialog, CupertinoDialogAction;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:signica/app/assets.dart';
import 'package:signica/app/theme/app_colors.dart';
import 'package:signica/app/theme/app_theme.dart';
import 'package:signica/app/widgets/app_icon.dart';
import 'package:signica/core/failure.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/entities/document_source.dart';
import 'package:signica/features/documents/presentation/bloc/documents_bloc.dart';
import 'package:signica/features/documents/presentation/pages/documents_page.dart';
import 'package:signica/features/documents/presentation/widgets/content_sheet.dart';
import 'package:signica/features/documents/presentation/widgets/document_actions_menu.dart';
import 'package:signica/features/documents/presentation/widgets/document_card.dart';
import 'package:signica/features/documents/presentation/widgets/document_preview.dart';
import 'package:signica/features/documents/presentation/widgets/documents_bottom_chrome.dart';
import 'package:signica/features/documents/presentation/widgets/documents_empty_state.dart';
import 'package:signica/features/documents/presentation/widgets/documents_filter_bar.dart';
import 'package:signica/features/documents/presentation/widgets/documents_grid.dart';
import 'package:signica/features/documents/presentation/widgets/documents_header.dart';
import 'package:signica/features/documents/presentation/widgets/documents_menu.dart';
import 'package:signica/features/documents/presentation/widgets/signed_badge.dart';
import 'package:signica/features/documents/presentation/widgets/source_pill.dart';

/// Layout conformance for the one screen in the app.
///
/// The numbers asserted here are the ones measured in Figma (`docs/ui-spec.md`)
/// on the 375pt frame the design is drawn on — so a layout regression fails the
/// suite instead of quietly drifting away from the mock-up.
class _MockDocumentsBloc extends MockBloc<DocumentsEvent, DocumentsState>
    implements DocumentsBloc {}

/// The design frame: 375×812.
const Size _designSize = Size(375, 812);

Document _document(
  String id,
  String name, {
  int pages = 1,
  bool signed = false,
}) => Document(
  id: id,
  name: name,
  filePath: '/tmp/$id.pdf',
  firstPagePreviewPath: '/tmp/$id-first.png',
  lastPagePreviewPath: pages > 1 ? '/tmp/$id-last.png' : null,
  pageCount: pages,
  createdAt: DateTime(2025, 4, 12),
  isSigned: signed,
);

/// The label also appears in the (closed) header menu, so the button is looked
/// up inside the bottom bar.
final Finder _addButton = find.descendant(
  of: find.byType(DocumentsBottomChrome),
  matching: find.text('Add Document'),
);

/// Finds a glyph by the asset it draws. Icons are SVG assets, not font code
/// points, so `find.byIcon` has nothing to match on.
Finder _glyph(String asset) => find.byWidgetPredicate(
  (Widget widget) => widget is AppIcon && widget.asset == asset,
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late _MockDocumentsBloc bloc;

  setUpAll(() async {
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    bloc = _MockDocumentsBloc();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required DocumentsState state,
    Size size = _designSize,
    double textScale = 1,
    Stream<DocumentsState>? states,
  }) async {
    whenListen(
      bloc,
      states ?? const Stream<DocumentsState>.empty(),
      initialState: state,
    );

    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = size * 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const <Locale>[Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: Builder(
          builder: (BuildContext context) => MaterialApp(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: MediaQuery.withClampedTextScaling(
              minScaleFactor: textScale,
              maxScaleFactor: textScale,
              child: BlocProvider<DocumentsBloc>.value(
                value: bloc,
                child: const DocumentsView(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('layout', () {
    testWidgets('segmented control matches the design box', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        state: const DocumentsState(status: DocumentsStatus.ready),
      );

      // The widget includes its own outer margin; the track is the box drawn
      // in Figma.
      final Size size = tester.getSize(
        find
            .descendant(
              of: find.byType(DocumentsFilterBar),
              matching: find.byType(Container),
            )
            .first,
      );
      // Figma: track 343×36 with a 16pt margin on each side.
      expect(size.height, 36);
      expect(size.width, _designSize.width - 16 * 2);
    });

    testWidgets('grid cards are 150 wide on the design frame', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        state: DocumentsState(
          status: DocumentsStatus.ready,
          documents: <Document>[
            _document('1', 'Document', pages: 2, signed: true),
            _document('2', 'Resume'),
          ],
        ),
      );

      final Iterable<Element> cards = find.byType(DocumentCard).evaluate();
      expect(cards.length, 2);

      for (final Element card in cards) {
        expect(
          tester.getSize(find.byWidget(card.widget)).width,
          moreOrLessEquals(150, epsilon: 0.01),
        );
      }

      // Columns start at x=28 and x=197 in Figma.
      final List<double> lefts =
          cards
              .map(
                (Element card) =>
                    tester.getTopLeft(find.byWidget(card.widget)).dx,
              )
              .toList()
            ..sort();
      expect(lefts.first, moreOrLessEquals(28, epsilon: 0.01));
      expect(lefts.last, moreOrLessEquals(197, epsilon: 0.01));
    });

    testWidgets('empty state offers all three sources', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        state: const DocumentsState(status: DocumentsStatus.ready),
      );

      expect(find.byType(DocumentsEmptyState), findsOneWidget);
      expect(find.byType(SourcePill), findsNWidgets(3));
      expect(tester.getSize(find.byType(SourcePill).first).height, 56);
    });

    testWidgets('the signature mark closes the bottom of a signed preview', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        state: DocumentsState(
          status: DocumentsStatus.ready,
          documents: <Document>[_document('1', 'Document', signed: true)],
        ),
      );

      final Rect badge = tester.getRect(find.byType(SignedBadge));
      final Rect preview = tester.getRect(find.byType(DocumentPreview));

      // Figma: a 40 disc centred on the preview, 4 above its bottom edge.
      expect(badge.size, const Size.square(40));
      expect(
        badge.center.dx,
        moreOrLessEquals(preview.center.dx, epsilon: .01),
      );
      expect(badge.bottom, moreOrLessEquals(preview.bottom - 4, epsilon: .01));
    });
  });

  group('interaction', () {
    testWidgets('a tap on a card asks the bloc to toggle the signature', (
      WidgetTester tester,
    ) async {
      final Document document = _document('1', 'Document');
      await pumpScreen(
        tester,
        state: DocumentsState(
          status: DocumentsStatus.ready,
          documents: <Document>[document],
        ),
      );

      await tester.tap(find.byType(DocumentCard));
      await tester.pump();

      verify(() => bloc.add(DocumentSignatureToggled(document))).called(1);
    });

    testWidgets('the add button opens the source overlay', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        state: DocumentsState(
          status: DocumentsStatus.ready,
          documents: <Document>[_document('1', 'Document')],
        ),
      );

      await tester.tap(_addButton);
      await tester.pumpAndSettle();

      final Finder pills = find.byType(SourcePill);
      expect(pills, findsNWidgets(3));

      // Figma: the overlay pills line up, at least 128 wide, right-aligned at
      // x=28. The rule is what is asserted, not one measurement: the shared
      // width is the widest label's, so it survives a longer translation.
      final List<double> widths = <double>[
        for (int i = 0; i < 3; i++) tester.getSize(pills.at(i)).width,
      ];
      expect(
        widths,
        everyElement(moreOrLessEquals(widths.first, epsilon: .01)),
      );
      expect(widths.first, greaterThanOrEqualTo(SourcePill.overlayMinWidth));

      for (int i = 0; i < 3; i++) {
        expect(
          tester.getBottomRight(pills.at(i)).dx,
          moreOrLessEquals(
            _designSize.width - ContentSheet.horizontalInset,
            epsilon: 0.01,
          ),
        );
      }
    });

    /// The design blurs the documents, not the screen: in the mock-up the dark
    /// header is as sharp with the picker open as without it. That makes the
    /// sheet's own clip the boundary of the filter, so the filter has to live
    /// inside it.
    testWidgets('the source overlay blurs the sheet and not the header', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        state: DocumentsState(
          status: DocumentsStatus.ready,
          documents: <Document>[_document('1', 'Document')],
        ),
      );

      expect(
        find.byType(BackdropFilter),
        findsNothing,
        reason: 'a blur of zero still costs a saveLayer every frame',
      );

      await tester.tap(_addButton);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(ContentSheet),
          matching: find.byType(BackdropFilter),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.byType(DocumentsHeader),
          matching: find.byType(BackdropFilter),
        ),
        findsNothing,
      );

      // And it paints *over* the cards rather than around them. A
      // `BackdropFilter` blurs what is already behind it, so wrapped around the
      // grid it would blur the empty surface underneath and leave the cards
      // sharp — which is exactly what it did until this was pinned.
      expect(
        find.ancestor(
          of: find.byType(DocumentsGrid),
          matching: find.byType(BackdropFilter),
        ),
        findsNothing,
      );
    });

    testWidgets('choosing a source starts the import', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        state: DocumentsState(
          status: DocumentsStatus.ready,
          documents: <Document>[_document('1', 'Document')],
        ),
      );

      await tester.tap(_addButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Files'));
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(
          const DocumentImportRequested(
            source: DocumentSource.files,
            defaultName: 'New Document',
          ),
        ),
      ).called(1);
    });

    testWidgets('search expands the field and reports the query', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        state: DocumentsState(
          status: DocumentsStatus.ready,
          documents: <Document>[_document('1', 'Document')],
        ),
      );

      await tester.tap(_glyph(AppIcons.searchSemibold));
      await tester.pumpAndSettle();

      final Finder field = find.byType(EditableText);
      expect(field, findsOneWidget);

      await tester.enterText(field, 'res');
      await tester.pump(const Duration(milliseconds: 300));

      verify(() => bloc.add(const DocumentsQueryChanged('res'))).called(1);
    });

    testWidgets('the header menu opens and offers select', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        state: DocumentsState(
          status: DocumentsStatus.ready,
          documents: <Document>[_document('1', 'Document')],
        ),
      );

      await tester.tap(_glyph(AppIcons.ellipsis));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentsMenu), findsOneWidget);
      expect(tester.getSize(find.byType(DocumentsMenu)).width, 262);

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      // Select mode replaces the title with the select-all action.
      expect(find.text('Select All'), findsOneWidget);
    });

    /// A button is its whole surface. Tapping the glass or the fill around the
    /// glyph has to work, not only the glyph itself.
    testWidgets('buttons take a tap anywhere on their surface', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        state: DocumentsState(
          status: DocumentsStatus.ready,
          documents: <Document>[_document('1', 'Document')],
        ),
      );

      // The menu stays in the tree while closed, so the proof that the corner
      // of the tile took the tap is that the menu became usable.
      final Rect tile = tester.getRect(find.byType(HeaderTile));
      await tester.tapAt(tile.topLeft + const Offset(3, 3));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      expect(find.text('Select All'), findsOneWidget);

      await tester.tap(find.byType(HeaderTile));
      await tester.pumpAndSettle();

      final Rect addButton = tester.getRect(
        find.ancestor(of: _addButton, matching: find.byType(GlassContainer)),
      );
      await tester.tapAt(addButton.centerLeft + const Offset(3, 0));
      await tester.pumpAndSettle();
      expect(find.byType(SourcePill), findsNWidgets(3));
    });

    testWidgets('select mode centres the marks and closes on the right', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        state: DocumentsState(
          status: DocumentsStatus.ready,
          documents: <Document>[_document('1', 'Document')],
        ),
      );

      await tester.tap(_glyph(AppIcons.ellipsis));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      // The close button keeps the 16 side margin of the design frame.
      final Finder close = find.byType(HeaderTile);
      expect(tester.getSize(close), const Size.square(38));
      expect(
        tester.getRect(close).right,
        moreOrLessEquals(_designSize.width - 16, epsilon: 0.01),
      );

      // The mark sits in the middle of the preview, not in a corner.
      final Rect mark = tester.getRect(find.byType(SelectionMark));
      final Rect preview = tester.getRect(find.byType(DocumentPreview));
      expect(mark.size, const Size.square(32));
      expect(mark.center.dx, moreOrLessEquals(preview.center.dx, epsilon: .01));
      expect(mark.center.dy, moreOrLessEquals(preview.center.dy, epsilon: .01));

      // Picking a card turns the action into "Deselect All (1)".
      await tester.tap(find.byType(DocumentCard));
      await tester.pumpAndSettle();
      expect(find.text('Deselect All (1)'), findsOneWidget);
    });

    testWidgets('the actions menu opens under the card it belongs to', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        state: DocumentsState(
          status: DocumentsStatus.ready,
          documents: <Document>[_document('1', 'Document')],
        ),
      );

      final Rect card = tester.getRect(find.byType(DocumentCard));

      await tester.longPress(find.byType(DocumentCard));
      await tester.pumpAndSettle();

      final Rect menu = tester.getRect(find.byType(DocumentActionsMenu));
      // Figma: a 250×137 panel at x=22, overlapping the card bottom by 9.
      expect(menu.width, 250);
      expect(menu.height, moreOrLessEquals(137, epsilon: 0.01));
      expect(menu.left, moreOrLessEquals(22, epsilon: 0.01));
      expect(menu.top, moreOrLessEquals(card.bottom - 9, epsilon: 0.01));
    });
  });

  group('adaptivity', () {
    /// The worst case the screen has to survive: the shortest phone, the
    /// largest Dynamic Type step, and a name that does not fit a card.
    testWidgets('survives a small screen at the largest text size', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        size: const Size(375, 667),
        textScale: 1.3,
        state: DocumentsState(
          status: DocumentsStatus.ready,
          documents: <Document>[
            _document('1', 'Contract on the sale of a residential property'),
            _document('2', 'Invoice'),
          ],
        ),
      );

      expect(tester.takeException(), isNull);
      // Two columns still fit, and the row is as tall as its tallest card.
      final Finder cards = find.byType(DocumentCard);
      expect(cards, findsNWidgets(2));
      expect(
        tester.getTopLeft(cards.first).dy,
        tester.getTopLeft(cards.last).dy,
      );
    });

    testWidgets('empty state scrolls instead of clipping', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        size: const Size(375, 667),
        textScale: 1.3,
        state: const DocumentsState(status: DocumentsStatus.ready),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SourcePill), findsNWidgets(3));
    });

    testWidgets('landscape widens the grid instead of squeezing the cards', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        size: const Size(812, 375),
        state: DocumentsState(
          status: DocumentsStatus.ready,
          documents: <Document>[
            for (int i = 0; i < 4; i++) _document('$i', 'Document $i'),
          ],
        ),
      );

      expect(tester.takeException(), isNull);
      // All four cards fit on one row, so none of them wraps.
      final Finder cards = find.byType(DocumentCard);
      expect(
        tester.getTopLeft(cards.first).dy,
        tester.getTopLeft(cards.last).dy,
      );
    });
  });

  /// `ThemeData` is easy to write and never read. The error dialog is the one
  /// screen the app does not build itself, so it is where the theme either
  /// carries something or is shown not to.
  ///
  /// Its typography deliberately is *not* asserted: `CupertinoAlertDialog`
  /// hard-codes `CupertinoSystemText` with `inherit: false`, and a system alert
  /// that came up in the app's own typeface would look wrong on iOS. What the
  /// dialog does take from the theme is the action colour, so that is what is
  /// pinned here.
  group('theme', () {
    testWidgets('the error dialog takes its action colour from the theme', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        state: const DocumentsState(status: DocumentsStatus.ready),
        states: Stream<DocumentsState>.value(
          const DocumentsState(
            status: DocumentsStatus.ready,
            failure: PdfFailure(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);

      // The action label, not the message: that is the one piece of the
      // dialog Cupertino resolves through the theme.
      final RichText message = tester.widget<RichText>(
        find
            .descendant(
              of: find.byType(CupertinoDialogAction),
              matching: find.byType(RichText),
            )
            .first,
      );

      expect(message.text.style?.color, AppColors.textPrimary);
    });
  });
}
