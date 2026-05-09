import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/domain/enums/app_theme_mode.dart';
import 'package:task_nest/domain/usecases/app_preferences_use_cases.dart';
import 'package:task_nest/infrastructure/di/injection.dart';
import 'package:task_nest/presentation/theme/theme_helper.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SetThemeModeUseCase _setThemeMode;

  ThemeCubit(super.initialMode)
    : _setThemeMode = DI.container<SetThemeModeUseCase>();

  void toggleLight() => _apply(ThemeMode.light);

  void toggleDark() => _apply(ThemeMode.dark);

  void _apply(ThemeMode newTheme) {
    if (state == newTheme) return;
    ThemeHelper.changeNativeBarColors(newTheme);
    emit(newTheme);
    _setThemeMode.call(
      newTheme == ThemeMode.dark ? AppThemeMode.dark : AppThemeMode.light,
    );
  }
}
