import 'package:task_nest/domain/entities/daily_brief_settings.dart';
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

class GetDailyBriefSettingsUseCase {
  final AppPreferencesRepository repository;

  GetDailyBriefSettingsUseCase(this.repository);

  Future<DailyBriefSettings> call() => repository.getDailyBriefSettings();
}

class SetDailyBriefSettingsUseCase {
  final AppPreferencesRepository repository;

  SetDailyBriefSettingsUseCase(this.repository);

  Future<void> call(DailyBriefSettings settings) =>
      repository.setDailyBriefSettings(settings);
}
