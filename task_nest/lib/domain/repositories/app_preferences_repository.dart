import 'package:task_nest/domain/entities/daily_brief_settings.dart';
import 'package:task_nest/domain/enums/app_theme_mode.dart';

abstract class AppPreferencesRepository {
  Future<AppThemeMode> getThemeMode();
  Future<void> setThemeMode(AppThemeMode mode);

  Future<String?> getLocaleKey();
  Future<void> setLocaleKey(String localeKey);

  Future<bool> getNotificationsMuted();
  Future<void> setNotificationsMuted(bool muted);

  Future<DailyBriefSettings> getDailyBriefSettings();
  Future<void> setDailyBriefSettings(DailyBriefSettings settings);
}
