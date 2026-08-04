import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart';

/// Opens the app database.
///
/// The app links against the SQLite that ships with iOS instead of vendoring
/// its own build: `sqlite3_flutter_libs` compiles SQLite from sources it
/// downloads at `pod install` time, which makes the build depend on a network
/// fetch. The schema here uses nothing beyond plain SQL, so the system library
/// is enough — and the project builds from a clean checkout without it.
QueryExecutor openDatabaseConnection() {
  _useSystemSqliteOnApple();

  return LazyDatabase(() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dir.path, 'signica.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

void _useSystemSqliteOnApple() {
  DynamicLibrary openSystem() {
    try {
      return DynamicLibrary.open('libsqlite3.dylib');
    } on ArgumentError {
      // Statically linked into the process on some iOS configurations.
      return DynamicLibrary.process();
    }
  }

  open
    ..overrideFor(OperatingSystem.iOS, openSystem)
    ..overrideFor(OperatingSystem.macOS, openSystem);
}
