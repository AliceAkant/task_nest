import 'package:task_nest/domain/enums/app_theme_mode.dart';

abstract class AppPreferencesRepository {
  Future<AppThemeMode> getThemeMode();
  Future<void> setThemeMode(AppThemeMode mode);

  Future<String?> getLocaleKey();
  Future<void> setLocaleKey(String localeKey);

  Future<bool> getNotificationsMuted();
  Future<void> setNotificationsMuted(bool muted);
}
