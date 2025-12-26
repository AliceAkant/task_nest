import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_nest/presentation/theme/app_colors.dart';

class ThemeHelper {
  /// Set native nav bar color (Android)
  static void changeNativeBarColors(ThemeMode mode) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.getDefaultBGColor(mode),
        systemNavigationBarIconBrightness: mode == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }
}
