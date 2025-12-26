import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_nest/infrastructure/storage/drift/drift_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Members, Events])
class AppDatabase extends _$AppDatabase {
  static const _databaseName = "task_nest_db";
  static const _databaseVersion = 1;

  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => _databaseVersion;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: _databaseName,
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {},
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
