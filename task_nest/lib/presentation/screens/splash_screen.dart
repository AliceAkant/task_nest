import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_nest/presentation/blocs/splash/splash_cubit.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';
import 'package:task_nest/presentation/helpers/assets_helper.dart';
import 'package:task_nest/presentation/helpers/health_check_service.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final healthCheckResult = HealthCheckService.isStable(context);

    if (healthCheckResult.isStable) {
      return BlocProvider(
        create: (context) => SplashCubit(context.read<UserCubit>())..startApp(),
        child: BlocListener<SplashCubit, SplashState>(
          listener: (context, state) {
            if (state is SplashFinished) {
              context.go(state.route);
            }
          },
          child: _splashView(),
        ),
      );
    } else {
      return _splashView(devInfo: healthCheckResult.info);
    }
  }

  Widget _splashView({String? devInfo}) {
    return Scaffold(
      backgroundColor: Color(0xFF6029F5),
      body: Stack(
        children: [
          Center(child: AssetsHelper.getPngImage('task_nest_logo')),
          if (devInfo != null)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: BaseText(
                  devInfo,
                  align: TextAlign.center,
                  maxLines: 8,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
