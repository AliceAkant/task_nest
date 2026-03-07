import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_nest/presentation/theme/app_colors.dart';

class ThemeHelper {
  /// Set native nav bar color (Android)
  static void changeNativeBarColors(ThemeMode mode) {
    final isDark = mode == ThemeMode.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // Navigation bar (Android)
        systemNavigationBarColor: AppColors.getDefaultBGColor(mode),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        // Status bar
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // Android
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,     // iOS
      ),
    );
  }
}
