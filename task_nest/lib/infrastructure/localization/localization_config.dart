import 'package:flutter/material.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/infrastructure/localization/localization_model.dart';

class LocalizationConfig {
  static const path = 'assets/translations';

  static List<LocalizationModel> get localizations {
    return [
      LocalizationModel(
        locale: const Locale('ru', 'RU'),
        name: LocaleKeys.russian,
      ),
      LocalizationModel(
        locale: const Locale('en', 'US'),
        name: LocaleKeys.english,
      ),
    ];
  }

  static List<Locale> get supportedLocales =>
      localizations.map((l) => l.locale).toList();

  static LocalizationModel get defaultLocalization => localizations.first;
}
