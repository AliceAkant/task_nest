import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/repositories/members_repository.dart';

class GetMembersUseCase {
  final MembersRepository repository;

  GetMembersUseCase(this.repository);

  Future<Either<Failure, List<Member>>> call() => repository.getMembers();
}

class AddMemberUseCase {
  final MembersRepository repository;

  AddMemberUseCase(this.repository);

  Future<Either<Failure, Member>> call(Member member) =>
      repository.addMember(member);
}

class UpdateMemberUseCase {
  final MembersRepository repository;

  UpdateMemberUseCase(this.repository);

  Future<Either<Failure, Member>> call(Member member) =>
      repository.updateMember(member);
}

class DeleteMemberUseCase {
  final MembersRepository repository;

  DeleteMemberUseCase(this.repository);

  Future<Either<Failure, bool>> call(int memberId) =>
      repository.deleteMember(memberId);
}
