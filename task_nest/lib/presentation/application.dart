import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/infrastructure/routes/app_router.dart';
import 'package:task_nest/presentation/theme/app_colors.dart';
import 'package:task_nest/presentation/theme/theme_helper.dart';

class Application extends StatelessWidget {
  final ThemeMode themeMode;
  const Application({required this.themeMode, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: tr(LocaleKeys.appName),
      // Theme
      themeMode: themeMode,
      theme: ThemeData(
        extensions: const <ThemeExtension<dynamic>>[AppColors.light],
      ),
      darkTheme: ThemeData(
        extensions: const <ThemeExtension<dynamic>>[AppColors.dark],
      ),
      // Routing
      routeInformationProvider: AppRouter.router.routeInformationProvider,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routerDelegate: AppRouter.router.routerDelegate,
      // Localization
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      builder: (context, child) {
        ThemeHelper.changeNativeBarColors(themeMode);
        return child ?? const SizedBox();
      },
    );
  }
}
