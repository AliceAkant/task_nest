import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_nest/domain/usecases/notifications_use_cases.dart';
import 'package:task_nest/infrastructure/di/injection.dart';
import 'package:task_nest/infrastructure/routes/app_routes.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final UserCubit _userCubit;
  final RequestNotificationPermissionUseCase _requestPermissionUC;
  final RescheduleDailyBriefUseCase _rescheduleDailyBriefUC;

  SplashCubit(this._userCubit)
    : _requestPermissionUC =
          DI.container<RequestNotificationPermissionUseCase>(),
      _rescheduleDailyBriefUC = DI.container<RescheduleDailyBriefUseCase>(),
      super(SplashInitial());

  Future startApp() async {
    // Animation of splash + concurrent loads + first-launch permission prompt.
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      _userCubit.loadUser(),
      _requestPermissionUC.call(),
    ]);

    // Refresh daily-brief schedule after permission is settled and events
    // datasource is ready. Run independently of user route.
    unawaited(_rescheduleDailyBriefUC.call());

    final initialScreen = _userCubit.state != null
        ? AppRoutes.schedule
        : AppRoutes.greeting;

    emit(SplashFinished(route: initialScreen));
  }
}
