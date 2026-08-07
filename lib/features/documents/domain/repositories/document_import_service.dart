import 'package:signica/core/result.dart';
import 'package:signica/features/documents/domain/entities/document_source.dart';
import 'package:signica/features/documents/domain/entities/picked_source.dart';
import 'package:signica/features/documents/domain/entities/stored_pdf.dart';

/// Everything between "user tapped a source" and "there is a PDF on disk with
/// its previews rendered". Platform pickers, PDF generation and rasterisation
/// live behind this single boundary.
abstract interface class DocumentImportService {
  /// Opens the picker for [source]. Returns [PickerCancelled] when the user
  /// backs out without choosing anything.
  Future<Result<PickedSource>> pick(DocumentSource source);

  /// Stores [picked] as a PDF under [documentId] and renders the first and
  /// last page previews. Images are assembled into a PDF first; an already
  /// picked PDF is copied as-is.
  Future<Result<StoredPdf>> store({
    required PickedSource picked,
    required String documentId,
  });
}
