import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:injectable/injectable.dart';
// `pdf` (writing) and `pdfrx` (reading) both export PdfDocument/PdfPage/PdfImage,
// so each side is imported behind its own name.
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:signica/features/documents/data/sources/file_storage.dart';

/// Raised when a page cannot be rasterised or its preview cannot be encoded.
///
/// A dedicated type rather than [StateError] so the layer above can classify
/// it by type. It used to be told apart by looking for `'pdf'` in the message,
/// which is not a contract and breaks the moment the wording changes.
class PdfRenderException implements Exception {
  const PdfRenderException(this.message);

  final String message;

  @override
  String toString() => 'PdfRenderException: $message';
}

/// Result of rendering a document's preview pages.
class RenderedPreviews {
  const RenderedPreviews({
    required this.firstPagePath,
    required this.pageCount,
    this.lastPagePath,
  });

  final String firstPagePath;
  final String? lastPagePath;
  final int pageCount;
}

/// PDF generation and page rasterisation.
///
/// Previews are rasterised exactly once, when a document is added. The grid
/// then only shows PNG files — no `PdfView`, no re-rendering while scrolling.
@lazySingleton
class PdfProcessor {
  PdfProcessor(this._storage);

  /// Card preview is 150pt wide; 3x covers the densest iPhone screens.
  static const double _previewWidth = 450;

  final FileStorage _storage;

  /// Assembles [imagePaths] into a single PDF, one image per page.
  Future<void> buildPdfFromImages({
    required List<String> imagePaths,
    required String targetPath,
  }) async {
    final pw.Document doc = pw.Document();

    for (final String path in imagePaths) {
      final File file = File(path);
      // The scanner plugin writes its pages with `try?` and returns the paths
      // either way, so a failed write (a full disk, most often) reaches us as a
      // path to nothing. Reported here, while the file name is still known,
      // instead of as an opaque read error further down.
      if (!await file.exists()) {
        throw PathNotFoundException(
          path,
          const OSError('scanned page was never written'),
        );
      }

      final Uint8List bytes = await file.readAsBytes();
      final pw.MemoryImage image = pw.MemoryImage(bytes);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) =>
              pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ),
      );
    }

    // `save()` already returns a `Uint8List`; copying it held a second full
    // document in memory at the moment the first one was still alive.
    await _storage.writeBytes(targetPath, await doc.save());
  }

  /// Renders the first page — and the last one, when the document has more
  /// than a single page — into PNG files next to the document.
  Future<RenderedPreviews> renderPreviews({
    required String pdfPath,
    required String documentId,
  }) async {
    final pdfrx.PdfDocument document = await pdfrx.PdfDocument.openFile(
      pdfPath,
    );
    try {
      final int pageCount = document.pages.length;

      final String firstPath = await _renderPage(
        page: document.pages.first,
        documentId: documentId,
        label: 'first',
      );

      String? lastPath;
      if (pageCount > 1) {
        lastPath = await _renderPage(
          page: document.pages.last,
          documentId: documentId,
          label: 'last',
        );
      }

      return RenderedPreviews(
        firstPagePath: firstPath,
        lastPagePath: lastPath,
        pageCount: pageCount,
      );
    } finally {
      await document.dispose();
    }
  }

  Future<String> _renderPage({
    required pdfrx.PdfPage page,
    required String documentId,
    required String label,
  }) async {
    final double fullHeight = _previewWidth * page.height / page.width;
    final pdfrx.PdfImage? rendered = await page.render(
      fullWidth: _previewWidth,
      fullHeight: fullHeight,
      backgroundColor: 0xFFFFFFFF,
    );
    if (rendered == null) {
      throw PdfRenderException(
        'Failed to render page ${page.pageNumber} of $documentId',
      );
    }

    try {
      final ui.Image image = await rendered.createImage();
      try {
        final ByteData? png = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (png == null) {
          throw PdfRenderException('Failed to encode preview for $documentId');
        }
        final String path = _storage.previewPath(documentId, label);
        await _storage.writeBytes(path, png.buffer.asUint8List());
        return path;
      } finally {
        image.dispose();
      }
    } finally {
      rendered.dispose();
    }
  }
}
