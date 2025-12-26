import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:task_nest/infrastructure/localization/localization_config.dart';
import 'package:task_nest/infrastructure/localization/localization_model.dart';
import 'package:task_nest/core/shared_prefs/shared_preferences_factory.dart';
import 'package:task_nest/core/shared_prefs/shared_preferences_keys.dart';

class SharedPreferencesHelper {
  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferencesFactory.get();
    final savedTheme = prefs.getString(SharedPreferencesKeys.THEME_MODE);

    return savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  static Future setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferencesFactory.get();
    final themeStr = mode == ThemeMode.dark ? 'dark' : 'light';
    await prefs.setString(SharedPreferencesKeys.THEME_MODE, themeStr);
  }

  static Future<LocalizationModel?> getLocale() async {
    final prefs = await SharedPreferencesFactory.get();
    final savedLocaleKey = prefs.getString(SharedPreferencesKeys.LOCALE);
    final savedLocale = LocalizationConfig.localizations.firstWhereOrNull(
      (l) => l.localeKey == savedLocaleKey,
    );

    return savedLocale;
  }

  static Future setLocale(String localeKey) async {
    final prefs = await SharedPreferencesFactory.get();
    await prefs.setString(SharedPreferencesKeys.LOCALE, localeKey);
  }
}
