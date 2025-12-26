import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/core/logger/logger_helper.dart';
import 'package:task_nest/data/datasources/local/members_local_datasource.dart';
import 'package:task_nest/data/dto_models/local/member_drift_dto.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/repositories/members_repository.dart';

class MembersRepositoryImpl implements MembersRepository {
  final MembersLocalDataSource local;

  MembersRepositoryImpl(this.local);

  @override
  Future<Either<Failure, List<Member>>> getMembers() async {
    LoggerHelper.info('Try load members');

    final result = await local.getMembers();

    return result.fold(
      (failure) {
        LoggerHelper.databaseError('Load members failed: ${failure.message}');
        return Left(failure);
      },
      (list) {
        LoggerHelper.info('Load members success: ${list.length} items');
        return Right(list.map((e) => e.toEntity()).toList());
      },
    );
  }

  @override
  Future<Either<Failure, Member>> addMember(Member member) async {
    LoggerHelper.info('Try add member: ${member.toString()}');

    final dto = MemberDriftDto.fromEntity(member);

    final result = await local.addMember(dto);

    return result.fold(
      (failure) {
        LoggerHelper.databaseError('Add member failed: ${failure.message}');
        return Left(failure);
      },
      (savedDTO) {
        LoggerHelper.info('Add member success: [id: ${savedDTO.id}]');
        return Right(savedDTO.toEntity());
      },
    );
  }

  @override
  Future<Either<Failure, Member>> updateMember(Member member) async {
    LoggerHelper.info('Try update member: ${member.toString()}');

    final dto = MemberDriftDto.fromEntity(member);

    final result = await local.editMember(dto);

    return result.fold(
      (failure) {
        LoggerHelper.databaseError(
          'Update member ${member.id} failed: ${failure.message}',
        );
        return Left(failure);
      },
      (updatedDTO) {
        LoggerHelper.info('Update member ${member.id} success');
        return Right(updatedDTO.toEntity());
      },
    );
  }

  @override
  Future<Either<Failure, bool>> deleteMember(int memberId) async {
    LoggerHelper.info('Try delete member: $memberId');

    final result = await local.deleteMember(memberId);

    return result.fold(
      (failure) {
        LoggerHelper.databaseError('Delete member failed: ${failure.message}');
        return Left(failure);
      },
      (success) {
        LoggerHelper.info('Delete member $memberId success');
        return Right(success);
      },
    );
  }
}
