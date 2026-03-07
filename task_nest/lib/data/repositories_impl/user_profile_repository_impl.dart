import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/core/logger/logger_helper.dart';
import 'package:task_nest/data/datasources/shared_preferences_datasource.dart';
import 'package:task_nest/data/dto_models/user_dto.dart';
import 'package:task_nest/domain/entities/user_profile.dart';
import 'package:task_nest/domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final SharedPreferencesDataSource spDataSource;

  UserProfileRepositoryImpl(this.spDataSource);

  @override
  Future<Either<Failure, UserProfile>> initializeUser(
    UserProfile initialUser,
  ) async {
    LoggerHelper.info('Try initialize user: $initialUser');

    final dto = UserDto.fromEntity(initialUser);

    final result = await spDataSource.saveUser(dto);

    return result.fold(
      (failure) {
        LoggerHelper.databaseError(
          'User initialization failed: ${failure.message}',
        );
        return Left(failure);
      },
      (isSuccess) {
        LoggerHelper.info('Initialize user success');

        return Right(dto.toEntity());
      },
    );
  }

  @override
  Future<Either<Failure, UserProfile?>> getUser() async {
    LoggerHelper.info('Try get current user');

    final result = await spDataSource.getUser();

    return result.fold(
      (failure) {
        LoggerHelper.databaseError('Failed to get user: ${failure.message}');
        return Left(failure);
      },
      (user) {
        final userEntity = user?.toEntity();

        LoggerHelper.info('Current user: ${userEntity?.toString()}');
        return Right(userEntity);
      },
    );
  }

  @override
  Future<Either<Failure, bool>> updateUser(UserProfile user) async {
    LoggerHelper.info('Try update current user: ${user.toString()}');

    final dto = UserDto.fromEntity(user);

    final result = await spDataSource.saveUser(dto);

    return result.fold(
      (failure) {
        LoggerHelper.databaseError('Update user failed: ${failure.message}');
        return Left(failure);
      },
      (isSuccess) {
        LoggerHelper.info('Update user success');
        return Right(isSuccess);
      },
    );
  }
}
