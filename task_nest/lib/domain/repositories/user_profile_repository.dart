import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfile>> initializeUser(UserProfile initialUser);
  Future<Either<Failure, UserProfile?>> getUser();
  Future<Either<Failure, bool>> updateUser(UserProfile event);
}
