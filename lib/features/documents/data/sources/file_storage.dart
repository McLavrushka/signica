import 'dart:io';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Owns the app's on-disk layout: PDFs in `documents/`, rendered previews in
/// `previews/`. Nothing else in the app builds paths by hand.
///
/// Paths are handed out as absolute (widgets need them) but stored as relative
/// (`documents/<id>.pdf`). iOS moves the app container between installs, so an
/// absolute path written into the database stops resolving after an update —
/// see [relative] and [absolute].
@lazySingleton
class FileStorage {
  static const String _documents = 'documents';
  static const String _previews = 'previews';

  late final String _basePath;
  bool _isReady = false;

  /// Resolves the base directory once, at startup, so the rest of the app can
  /// convert paths synchronously.
  Future<void> init() async {
    if (_isReady) return;
    final Directory base = await getApplicationDocumentsDirectory();
    _basePath = base.path;
    await _ensure(_documents);
    await _ensure(_previews);
    _isReady = true;
  }

  String pdfPath(String documentId) =>
      p.join(_basePath, _documents, '$documentId.pdf');

  String previewPath(String documentId, String page) =>
      p.join(_basePath, _previews, '$documentId-$page.png');

  /// Path as stored in the database.
  String relative(String absolutePath) =>
      p.relative(absolutePath, from: _basePath);

  /// Path as used by the file system, rebuilt against the current container.
  String absolute(String relativePath) => p.isAbsolute(relativePath)
      ? relativePath
      : p.join(_basePath, relativePath);

  Future<File> copyTo(String sourcePath, String targetPath) =>
      File(sourcePath).copy(targetPath);

  Future<File> writeBytes(String targetPath, Uint8List bytes) =>
      File(targetPath).writeAsBytes(bytes, flush: true);

  /// Best-effort delete: a missing file is not an error when removing a
  /// document.
  Future<void> deleteIfExists(String? path) async {
    if (path == null) return;
    final File file = File(absolute(path));
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<void> _ensure(String name) async {
    final Directory dir = Directory(p.join(_basePath, name));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
  }
}
