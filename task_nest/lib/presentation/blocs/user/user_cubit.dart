import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/core/logger/logger_helper.dart';
import 'package:task_nest/domain/entities/user_profile.dart';
import 'package:task_nest/domain/entities/user_settings.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/domain/usecases/user/get_user_usecase.dart';
import 'package:task_nest/domain/usecases/user/initialize_user_usecase.dart';
import 'package:task_nest/domain/usecases/user/update_user_usecase.dart';
import 'package:task_nest/infrastructure/di/injection.dart';

class UserCubit extends Cubit<UserProfile?> {
  final InitializeUserUseCase _initializeUserUC;
  final GetUserUseCase _getUserUC;
  final UpdateUserUseCase _updateUserUC;

  UserCubit()
    : _initializeUserUC = DI.container<InitializeUserUseCase>(),
      _getUserUC = DI.container<GetUserUseCase>(),
      _updateUserUC = DI.container<UpdateUserUseCase>(),
      super(null);

  Future initializeUser(String name, Avatar avatar) async {
    final newUser = UserProfile(
      name: name,
      avatar: avatar,
      settings: UserSettings(),
    );

    final result = await _initializeUserUC.call(newUser);

    result.fold((failure) => emit(null), (user) => emit(user));
  }

  Future loadUser() async {
    final result = await _getUserUC.call();

    result.fold(
      (failure) => LoggerHelper.databaseError('Load user failed: ${failure.message}'),
      (user) => emit(user),
    );
  }

  Future<Either<Failure, bool>> update(UserProfile newUser) async {
    final result = await _updateUserUC.call(newUser);

    result.fold((failure) {}, (user) => emit(newUser));

    return result;
  }
}
