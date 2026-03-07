import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_nest/infrastructure/routes/app_routes.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final UserCubit _userCubit;

  SplashCubit(this._userCubit) : super(SplashInitial());

  Future startApp() async {
    // Animation of splash
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      _userCubit.loadUser(),
    ]);

    final initialScreen = _userCubit.state != null
        ? AppRoutes.schedule
        : AppRoutes.greeting;

    emit(SplashFinished(route: initialScreen));
  }
}
