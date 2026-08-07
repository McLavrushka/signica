import 'dart:io';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:printing/printing.dart';
import 'package:signica/core/failure.dart';
import 'package:signica/core/result.dart';
import 'package:signica/features/documents/domain/entities/document.dart';
import 'package:signica/features/documents/domain/repositories/document_exporter.dart';

@LazySingleton(as: DocumentExporter)
class DocumentExporterImpl implements DocumentExporter {
  const DocumentExporterImpl();

  @override
  Future<Result<void>> share(List<Document> documents) async {
    try {
      // The system sheet handles one file at a time, so several documents are
      // shared one after another.
      for (final Document document in documents) {
        await Printing.sharePdf(
          bytes: await _bytesOf(document),
          filename: '${document.name}.pdf',
        );
      }
      return const Ok<void>(null);
    } on Object catch (error) {
      return Err<void>(StorageFailure(cause: error));
    }
  }

  @override
  Future<Result<void>> print(Document document) async {
    try {
      await Printing.layoutPdf(
        onLayout: (_) => _bytesOf(document),
        name: document.name,
      );
      return const Ok<void>(null);
    } on Object catch (error) {
      return Err<void>(PdfFailure(cause: error));
    }
  }

  Future<Uint8List> _bytesOf(Document document) =>
      File(document.filePath).readAsBytes();
}
