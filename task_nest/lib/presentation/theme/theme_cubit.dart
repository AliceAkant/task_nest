import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/infrastructure/storage/sp/shared_preferences_helper.dart';
import 'package:task_nest/presentation/theme/theme_helper.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(super.initialMode);

  void toggleLight() {
    if (state != ThemeMode.light) {
      var newTheme = ThemeMode.light;

      ThemeHelper.changeNativeBarColors(newTheme);

      emit(newTheme);

      SharedPreferencesHelper.setThemeMode(newTheme);
    }
  }

  void toggleDark() {
    if (state != ThemeMode.dark) {
      var newTheme = ThemeMode.dark;

      ThemeHelper.changeNativeBarColors(newTheme);

      emit(newTheme);

      SharedPreferencesHelper.setThemeMode(newTheme);
    }
  }
}
