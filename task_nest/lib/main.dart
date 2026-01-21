import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/infrastructure/localization/localization_model.dart';
import 'package:task_nest/infrastructure/storage/sp/shared_preferences_helper.dart';
import 'package:task_nest/presentation/application.dart';
import 'package:task_nest/infrastructure/di/injection.dart';
import 'package:task_nest/infrastructure/localization/localization_config.dart';
import 'package:task_nest/presentation/blocs/events_count/events_count_cubit.dart';
import 'package:task_nest/presentation/blocs/localization/localization_cubit.dart';
import 'package:task_nest/presentation/blocs/members/members_cubit.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';
import 'package:task_nest/presentation/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await DI().initializeDependencies();

  final themeMode = await SharedPreferencesHelper.getThemeMode();

  final startLocale =
      await SharedPreferencesHelper.getLocale() ??
      LocalizationConfig.defaultLocalization;

  runApp(
    EasyLocalization(
      supportedLocales: LocalizationConfig.supportedLocales,
      path: LocalizationConfig.path,
      startLocale: startLocale.locale,
      fallbackLocale: LocalizationConfig.defaultLocalization.locale,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit(themeMode)),
          BlocProvider<LocalizationCubit>(
            create: (context) => LocalizationCubit(startLocale),
          ),
          BlocProvider(create: (_) => UserCubit()),
          BlocProvider(create: (_) => MembersCubit()..loadData()),
          BlocProvider(create: (_) => EventsCountCubit()..loadData()),
        ],
        child: BlocConsumer<LocalizationCubit, LocalizationModel>(
          listener: (context, localization) {
            if (context.locale != localization.locale) {
              context.setLocale(localization.locale);
            }
          },
          builder: (context, localization) {
            return BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return Application(themeMode: themeMode);
              },
            );
          },
        ),
      ),
    ),
  );
}
