import 'package:task_nest/domain/enums/app_theme_mode.dart';
import 'package:task_nest/domain/repositories/app_preferences_repository.dart';

class GetThemeModeUseCase {
  final AppPreferencesRepository repository;

  GetThemeModeUseCase(this.repository);

  Future<AppThemeMode> call() => repository.getThemeMode();
}

class SetThemeModeUseCase {
  final AppPreferencesRepository repository;

  SetThemeModeUseCase(this.repository);

  Future<void> call(AppThemeMode mode) => repository.setThemeMode(mode);
}

class GetLocaleKeyUseCase {
  final AppPreferencesRepository repository;

  GetLocaleKeyUseCase(this.repository);

  Future<String?> call() => repository.getLocaleKey();
}

class SetLocaleKeyUseCase {
  final AppPreferencesRepository repository;

  SetLocaleKeyUseCase(this.repository);

  Future<void> call(String localeKey) => repository.setLocaleKey(localeKey);
}
