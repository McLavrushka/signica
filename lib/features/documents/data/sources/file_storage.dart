import 'dart:io';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Owns the app's on-disk layout: PDFs in `documents/`, rendered previews in
/// `previews/`. Nothing else in the app builds paths by hand.
@lazySingleton
class FileStorage {
  Directory? _documentsDir;
  Directory? _previewsDir;

  Future<Directory> get documentsDir async =>
      _documentsDir ??= await _ensure('documents');

  Future<Directory> get previewsDir async =>
      _previewsDir ??= await _ensure('previews');

  Future<String> pdfPath(String documentId) async =>
      p.join((await documentsDir).path, '$documentId.pdf');

  Future<String> previewPath(String documentId, String page) async =>
      p.join((await previewsDir).path, '$documentId-$page.png');

  Future<File> copyTo(String sourcePath, String targetPath) =>
      File(sourcePath).copy(targetPath);

  Future<File> writeBytes(String targetPath, Uint8List bytes) =>
      File(targetPath).writeAsBytes(bytes, flush: true);

  /// Best-effort delete: a missing file is not an error when removing a
  /// document.
  Future<void> deleteIfExists(String? path) async {
    if (path == null) return;
    final File file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<Directory> _ensure(String name) async {
    final Directory base = await getApplicationDocumentsDirectory();
    final Directory dir = Directory(p.join(base.path, name));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
