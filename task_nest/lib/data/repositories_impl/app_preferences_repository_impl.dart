import 'package:task_nest/core/shared_prefs/shared_preferences_factory.dart';
import 'package:task_nest/core/shared_prefs/shared_preferences_keys.dart';
import 'package:task_nest/domain/enums/app_theme_mode.dart';
import 'package:task_nest/domain/repositories/app_preferences_repository.dart';

class AppPreferencesRepositoryImpl implements AppPreferencesRepository {
  @override
  Future<AppThemeMode> getThemeMode() async {
    final prefs = await SharedPreferencesFactory.get();
    final saved = prefs.getString(SharedPreferencesKeys.THEME_MODE);
    return saved == 'dark' ? AppThemeMode.dark : AppThemeMode.light;
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferencesFactory.get();
    await prefs.setString(
      SharedPreferencesKeys.THEME_MODE,
      mode == AppThemeMode.dark ? 'dark' : 'light',
    );
  }

  @override
  Future<String?> getLocaleKey() async {
    final prefs = await SharedPreferencesFactory.get();
    return prefs.getString(SharedPreferencesKeys.LOCALE);
  }

  @override
  Future<void> setLocaleKey(String localeKey) async {
    final prefs = await SharedPreferencesFactory.get();
    await prefs.setString(SharedPreferencesKeys.LOCALE, localeKey);
  }

  @override
  Future<bool> getNotificationsMuted() async {
    final prefs = await SharedPreferencesFactory.get();
    return prefs.getBool(SharedPreferencesKeys.NOTIFICATIONS_MUTED) ?? false;
  }

  @override
  Future<void> setNotificationsMuted(bool muted) async {
    final prefs = await SharedPreferencesFactory.get();
    await prefs.setBool(SharedPreferencesKeys.NOTIFICATIONS_MUTED, muted);
  }
}
