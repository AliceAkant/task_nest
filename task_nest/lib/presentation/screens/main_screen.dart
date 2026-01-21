import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/infrastructure/routes/app_routes.dart';
import 'package:task_nest/presentation/blocs/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:task_nest/presentation/blocs/schedule/schedule_cubit.dart';
import 'package:task_nest/presentation/blocs/settings/settings_cubit.dart';
import 'package:task_nest/presentation/enum/app_svg.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/models/tab_item.dart';
import 'package:task_nest/presentation/screens/schedule_screen.dart';
import 'package:task_nest/presentation/screens/settings_screen.dart';
import 'package:task_nest/presentation/widgets/views/bottom_nav_bar_view.dart';

class MainScreen extends StatelessWidget {
  final PageController _pageController = PageController();

  MainScreen({super.key});

  final List<TabItem> tabs = [
    TabItem(
      AppRoutes.schedule,
      LocaleKeys.schedule,
      AppSvg.calendarEdit,
      ScheduleScreen(key: PageStorageKey('schedule')),
    ),
    TabItem(
      AppRoutes.settings,
      LocaleKeys.settings,
      AppSvg.settings,
      SettingsScreen(key: PageStorageKey('settings')),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavigationCubit, BottomNavigationState>(
      buildWhen: (previous, current) => previous.index != current.index,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.colors.background,
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: tabs.map((e) => e.screenView).toList(),
          ),
          bottomNavigationBar: BottomNavBarView(
            tabs: tabs,
            currentIndex: state.index,
            onTap: (index) {
              if (state.index != index) {
                final navCubit = context.read<BottomNavigationCubit>();
                navCubit.setNavBarItem(index);
                _pageController.jumpToPage(index);

                if (index == 0) {
                  context.read<ScheduleCubit>().tabOpened();
                } else if (index == 1) {
                  context.read<SettingsCubit>().tabOpened();
                }
              }
            },
          ),
        );
      },
    );
  }
}
