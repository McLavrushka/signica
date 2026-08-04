import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:signica/features/documents/data/sources/file_storage.dart';
import 'package:signica/features/documents/data/sources/pdf_processor.dart';

/// Exercises the parts that only work on a real engine: PDF generation with
/// `pdf` and page rasterisation with `pdfrx` (PDFium).
Future<String> _writeTestImage(String name, Color color) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 600, 800),
    Paint()..color = color,
  );
  final ui.Image image = await recorder.endRecording().toImage(600, 800);
  final ByteData? bytes = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  image.dispose();

  final Directory dir = await getTemporaryDirectory();
  final File file = File(p.join(dir.path, name));
  await file.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
  return file.path;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FileStorage storage;
  late PdfProcessor processor;

  setUpAll(() async {
    await pdfrxFlutterInitialize();
    storage = FileStorage();
    processor = PdfProcessor(storage);
  });

  testWidgets('builds a multi-page PDF from images and renders both previews', (
    WidgetTester tester,
  ) async {
    final List<String> images = <String>[
      await _writeTestImage('page-1.png', const Color(0xFFEEEEEE)),
      await _writeTestImage('page-2.png', const Color(0xFF999999)),
    ];

    const String id = 'integration-multi';
    final String target = await storage.pdfPath(id);

    await processor.buildPdfFromImages(imagePaths: images, targetPath: target);
    expect(File(target).existsSync(), isTrue);

    final RenderedPreviews previews = await processor.renderPreviews(
      pdfPath: target,
      documentId: id,
    );

    expect(previews.pageCount, 2);
    expect(File(previews.firstPagePath).existsSync(), isTrue);
    expect(previews.lastPagePath, isNotNull);
    expect(File(previews.lastPagePath!).existsSync(), isTrue);

    // The two pages differ, so their previews must differ as well: this is what
    // proves the last page is really rendered and not a copy of the first.
    expect(
      await File(previews.firstPagePath).readAsBytes(),
      isNot(equals(await File(previews.lastPagePath!).readAsBytes())),
    );
  });

  testWidgets('leaves the last preview empty for a single-page PDF', (
    WidgetTester tester,
  ) async {
    final List<String> images = <String>[
      await _writeTestImage('single.png', const Color(0xFFCCCCCC)),
    ];

    const String id = 'integration-single';
    final String target = await storage.pdfPath(id);

    await processor.buildPdfFromImages(imagePaths: images, targetPath: target);
    final RenderedPreviews previews = await processor.renderPreviews(
      pdfPath: target,
      documentId: id,
    );

    expect(previews.pageCount, 1);
    expect(previews.lastPagePath, isNull);
    expect(File(previews.firstPagePath).existsSync(), isTrue);
  });
}
