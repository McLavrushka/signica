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

  /// Long edge of a page handed to the PDF builder.
  ///
  /// A modern iPhone shoots 12–48 Mp; embedding that untouched costs tens of
  /// megabytes per page while adding nothing a printed A4 page can show. 2400px
  /// is ~200 dpi across A4, which is past what the previews or a print need.
  static const double _maxPageEdge = 2400;

  /// Re-encoding at [_imageQuality] also normalises HEIC into JPEG, which is
  /// the format the PDF writer can embed without decoding it first.
  static const int _imageQuality = 85;

  Future<PickedSource?> pickPhotos() async {
    final List<XFile> images = await _imagePicker.pickMultiImage(
      maxWidth: _maxPageEdge,
      maxHeight: _maxPageEdge,
      imageQuality: _imageQuality,
    );
    if (images.isEmpty) return null;

    return PickedImages(images.map((XFile image) => image.path).toList());
  }

  /// The plugin defaults to PNG, and PNG is the one format the PDF writer has
  /// to fully decode to RGBA and re-compress — roughly 50 MB of Dart heap per
  /// 12 Mp page, multiplied by the page count. JPEG is embedded byte for byte.
  Future<PickedSource?> scan() async {
    final List<String>? pages = await CunningDocumentScanner.getPictures(
      iosScannerOptions: const IosScannerOptions(
        imageFormat: IosImageFormat.jpg,
      ),
    );
    if (pages == null || pages.isEmpty) return null;

    return PickedImages(pages);
  }
}
