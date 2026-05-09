import 'package:drift/drift.dart';

class Members extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get hexColor => text()();
  TextColumn get avatarKey => text()();
}

class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get timeDate => dateTime()();
  IntColumn get durationMinutes =>
      integer().withDefault(const Constant(30))();
  TextColumn get notes => text().nullable()();

  // nullable foreign key on Member
  IntColumn get memberId => integer().nullable().references(
    Members,
    #id,
    onDelete: KeyAction.cascade,
  )();
}
