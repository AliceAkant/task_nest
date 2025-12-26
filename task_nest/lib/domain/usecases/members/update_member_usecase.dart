import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/repositories/members_repository.dart';

class UpdateMemberUseCase {
  final MembersRepository repository;

  UpdateMemberUseCase(this.repository);

  Future<Either<Failure, Member>> call(Member member) =>
      repository.updateMember(member);
}
