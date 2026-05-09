import 'package:task_nest/core/shared_prefs/shared_preferences_factory.dart';
import 'package:task_nest/core/shared_prefs/shared_preferences_keys.dart';
import 'package:task_nest/domain/entities/daily_brief_settings.dart';
import 'package:task_nest/domain/enums/app_theme_mode.dart';
import 'package:task_nest/domain/repositories/app_preferences_repository.dart';

class AppPreferencesRepositoryImpl implements AppPreferencesRepository {
  @override
  Future<AppThemeMode> getThemeMode() async {
    final prefs = await SharedPreferencesFactory.get();
    final saved = prefs.getString(SharedPreferencesKeys.THEME_MODE);
    switch (saved) {
      case 'dark':
        return AppThemeMode.dark;
      case 'light':
        return AppThemeMode.light;
      default:
        return AppThemeMode.system;
    }
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferencesFactory.get();
    final value = switch (mode) {
      AppThemeMode.dark => 'dark',
      AppThemeMode.light => 'light',
      AppThemeMode.system => 'system',
    };
    await prefs.setString(SharedPreferencesKeys.THEME_MODE, value);
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

  @override
  Future<DailyBriefSettings> getDailyBriefSettings() async {
    final prefs = await SharedPreferencesFactory.get();
    return DailyBriefSettings(
      enabled: prefs.getBool(SharedPreferencesKeys.DAILY_BRIEF_ENABLED) ?? false,
      hour: prefs.getInt(SharedPreferencesKeys.DAILY_BRIEF_HOUR) ??
          DailyBriefSettings.defaultHour,
      minute: prefs.getInt(SharedPreferencesKeys.DAILY_BRIEF_MINUTE) ??
          DailyBriefSettings.defaultMinute,
    );
  }

  @override
  Future<void> setDailyBriefSettings(DailyBriefSettings settings) async {
    final prefs = await SharedPreferencesFactory.get();
    await prefs.setBool(
      SharedPreferencesKeys.DAILY_BRIEF_ENABLED,
      settings.enabled,
    );
    await prefs.setInt(SharedPreferencesKeys.DAILY_BRIEF_HOUR, settings.hour);
    await prefs.setInt(
      SharedPreferencesKeys.DAILY_BRIEF_MINUTE,
      settings.minute,
    );
  }
}
