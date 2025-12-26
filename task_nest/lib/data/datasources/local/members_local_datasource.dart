import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/data/datasources/datasource_helper.dart';
import 'package:task_nest/data/dto_models/local/member_drift_dto.dart';
import 'package:task_nest/infrastructure/storage/drift/app_database.dart';

class MembersLocalDataSource {
  final AppDatabase db;

  MembersLocalDataSource(this.db);

  Future<Either<Failure, List<MemberDriftDto>>> getMembers() async {
    return DataSourceHelper.executeSafe(
      action: () async {
        final rows = await db.select(db.members).get();

        final result = rows.map((row) => _formatMemberDTO(row)).toList();

        return result;
      },
      errorTitle: "Failed to load all members",
    );
  }

  Future<Either<Failure, MemberDriftDto>> addMember(
    MemberDriftDto member,
  ) async {
    return DataSourceHelper.executeSafe(
      action: () async {
        final model = MembersCompanion.insert(
          name: member.name,
          hexColor: member.hexColor,
          avatarKey: member.avatarKey,
        );

        final id = await db.into(db.members).insert(model);

        return member.copyWith(id: id);
      },
      errorTitle: "Failed to add member",
    );
  }

  Future<Either<Failure, MemberDriftDto>> editMember(
    MemberDriftDto member,
  ) async {
    return DataSourceHelper.executeSafe(
      action: () async {
        final model = MembersCompanion(
          name: Value(member.name),
          hexColor: Value(member.hexColor),
          avatarKey: Value(member.avatarKey),
        );

        final query = db.update(db.members)
          ..where((tbl) => tbl.id.equals(member.id));

        await query.write(model);

        return member;
      },
      errorTitle: "Failed to edit member ${member.id}",
    );
  }

  Future<Either<Failure, bool>> deleteMember(int memberId) async {
    return DataSourceHelper.executeSafe(
      action: () async {
        final query = db.delete(db.members)
          ..where((m) => m.id.equals(memberId));

        final count = await query.go();

        return count > 0;
      },
      errorTitle: "Failed to delete member $memberId",
    );
  }

  ///
  /// HELPERS
  ///

  MemberDriftDto _formatMemberDTO(Member row) {
    return MemberDriftDto(
      id: row.id,
      name: row.name,
      hexColor: row.hexColor,
      avatarKey: row.avatarKey,
    );
  }
}
