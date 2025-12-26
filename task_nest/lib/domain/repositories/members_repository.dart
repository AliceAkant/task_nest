import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/entities/member.dart';

abstract class MembersRepository {
  Future<Either<Failure, List<Member>>> getMembers();
  Future<Either<Failure, Member>> addMember(Member member);
  Future<Either<Failure, Member>> updateMember(Member member);
  Future<Either<Failure, bool>> deleteMember(int memberId);
}
