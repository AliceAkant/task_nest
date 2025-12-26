import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/core/shared_prefs/shared_preferences_factory.dart';
import 'package:task_nest/core/shared_prefs/shared_preferences_keys.dart';
import 'package:task_nest/data/datasources/datasource_helper.dart';
import 'package:task_nest/data/dto_models/user_dto.dart';

class SharedPreferencesDataSource {
  Future<Either<Failure, UserDto?>> getUser() async {
    return DataSourceHelper.executeSafe(
      action: () async {
        final prefs = await SharedPreferencesFactory.get();
        final jsonString = prefs.getString(SharedPreferencesKeys.USER_PROFILE);

        if (jsonString != null) {
          final Map<String, dynamic> json = jsonDecode(jsonString);

          return UserDto.fromJson(json);
        }

        return null;
      },
      errorTitle: "Failed on get user",
    );
  }

  Future<Either<Failure, bool>> saveUser(UserDto user) async {
    return DataSourceHelper.executeSafe(
      action: () async {
        final prefs = await SharedPreferencesFactory.get();

        final isSuccess = await prefs.setString(
          SharedPreferencesKeys.USER_PROFILE,
          jsonEncode(user.toJson()),
        );

        return isSuccess;
      },
      errorTitle: "Failed on save user",
    );
  }
}
