import 'package:drift/drift.dart';
import 'package:signica/features/documents/data/db/database_connection.dart';
import 'package:signica/features/documents/data/db/document_rows.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: <Type>[DocumentRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabaseConnection());

  /// Test constructor: lets the DAO tests run against an in-memory database.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
