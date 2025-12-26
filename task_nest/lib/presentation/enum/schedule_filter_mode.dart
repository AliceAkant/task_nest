import 'package:task_nest/infrastructure/localization/locale_keys.dart';

enum DefaultScheduleFilterMode { all, onlyMine }

extension DefaultScheduleFilterModeExtension on DefaultScheduleFilterMode {
  String get titleKey {
    switch (this) {
      case DefaultScheduleFilterMode.all:
        return LocaleKeys.schedule_filter_mode_all_option;
      case DefaultScheduleFilterMode.onlyMine:
        return LocaleKeys.schedule_filter_mode_mine_option;
    }
  }
}
