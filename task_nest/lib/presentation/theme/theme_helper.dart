import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_nest/presentation/theme/app_colors.dart';

class ThemeHelper {
  /// Set native nav bar color (Android)
  static void changeNativeBarColors(ThemeMode mode) {
    final resolved = _resolve(mode);
    final isDark = resolved == ThemeMode.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // Navigation bar (Android)
        systemNavigationBarColor: AppColors.getDefaultBGColor(resolved),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        // Status bar
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // Android
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,     // iOS
      ),
    );
  }

  static ThemeMode _resolve(ThemeMode mode) {
    if (mode != ThemeMode.system) return mode;
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }
}
