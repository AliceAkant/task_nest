import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/infrastructure/routes/app_routes.dart';
import 'package:task_nest/presentation/blocs/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:task_nest/presentation/blocs/members/members_cubit.dart';
import 'package:task_nest/presentation/blocs/schedule/schedule_cubit.dart';
import 'package:task_nest/presentation/blocs/settings/settings_cubit.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';
import 'package:task_nest/presentation/screens/event_form_screen.dart';
import 'package:task_nest/presentation/screens/greeting_screen.dart';
import 'package:task_nest/presentation/screens/main_screen.dart';
import 'package:task_nest/presentation/screens/member_form_screen.dart';
import 'package:task_nest/presentation/screens/profile_screen.dart';
import 'package:task_nest/presentation/screens/splash_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) {
          return SplashScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.greeting,
        builder: (context, state) => GreetingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => BottomNavigationCubit()),
              BlocProvider(
                create: (context) => ScheduleCubit(
                  userCubit: context.read<UserCubit>(),
                  membersCubit: context.read<MembersCubit>(),
                ),
              ),
              BlocProvider(create: (_) => SettingsCubit()),
            ],
            child: MainScreen(),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.schedule,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SizedBox()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SizedBox()),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.addMember,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _transitionPage(key: state.pageKey, child: MemberFormScreen.add()),
      ),
      GoRoute(
        path: AppRoutes.editMember,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final member = state.extra as Member;
          return _transitionPage(
            key: state.pageKey,
            child: MemberFormScreen.edit(member: member),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addEvent,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final date = state.extra as DateTime?;
          return _transitionPage(
            key: state.pageKey,
            child: EventFormScreen.add(initialDate: date),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editEvent,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final event = state.extra as Event;
          return _transitionPage(
            key: state.pageKey,
            child: EventFormScreen.edit(event: event),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final userName = context.read<UserCubit>().state?.name;
          return _transitionPage(
            key: state.pageKey,
            child: ProfileScreen(username: userName),
          );
        },
      ),
    ],
  );

  static CustomTransitionPage _transitionPage({
    LocalKey? key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
