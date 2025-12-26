import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/repositories/members_repository.dart';

class DeleteMemberUseCase {
  final MembersRepository repository;

  DeleteMemberUseCase(this.repository);

  Future<Either<Failure, bool>> call(int memberId) {
    return repository.deleteMember(memberId);
  }
}
