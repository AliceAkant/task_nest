import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_nest/infrastructure/routes/app_routes.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final UserCubit _userCubit;

  SplashCubit(this._userCubit) : super(SplashInitial());

  Future startApp() async {
    String initialScreen = AppRoutes.greeting;
    bool isUserExist = false;

    // Animation of splash
    var delayTask = Future.delayed(const Duration(seconds: 3));

    var isExistTask = _userCubit.loadUser().then(
      (user) => isUserExist = _userCubit.state != null,
    );

    await Future.wait([delayTask, isExistTask]);

    initialScreen = isUserExist ? AppRoutes.schedule : AppRoutes.greeting;

    emit(SplashFinished(route: initialScreen));
  }
}
