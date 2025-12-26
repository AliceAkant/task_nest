import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/entities/user_profile.dart';
import 'package:task_nest/domain/repositories/user_profile_repository.dart';

class UpdateUserUseCase {
  final UserProfileRepository repository;

  UpdateUserUseCase(this.repository);

  Future<Either<Failure, bool>> call(UserProfile user) =>
      repository.updateUser(user);
}
