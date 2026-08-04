import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:signica/features/documents/domain/entities/picked_source.dart';

/// Thin wrapper over the three platform pickers.
///
/// Returns `null` when the user cancels — the caller turns that into
/// [PickerCancelled] so no exception is used for a normal user action.
@lazySingleton
class DocumentPicker {
  DocumentPicker(this._imagePicker);

  final ImagePicker _imagePicker;

  /// Files: PDFs only, enforced by the picker itself.
  Future<PickedSource?> pickPdf() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['pdf'],
    );

    final String? path = result?.files.single.path;
    if (path == null) return null;

    return PickedPdf(
      path: path,
      originalName: p.basenameWithoutExtension(
        result?.files.single.name ?? path,
      ),
    );
  }

  Future<PickedSource?> pickPhotos() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isEmpty) return null;

    return PickedImages(images.map((XFile image) => image.path).toList());
  }

  Future<PickedSource?> scan() async {
    final List<String>? pages = await CunningDocumentScanner.getPictures();
    if (pages == null || pages.isEmpty) return null;

    return PickedImages(pages);
  }
}
