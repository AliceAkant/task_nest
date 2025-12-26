part of 'splash_cubit.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashError extends SplashState {
  final bool memberCubitExist;
  final bool userCubitExist;

  const SplashError({
    required this.memberCubitExist,
    required this.userCubitExist,
  });

  @override
  List<Object> get props => [memberCubitExist, userCubitExist];
}

class SplashFinished extends SplashState {
  final String route;

  const SplashFinished({required this.route});

  @override
  List<Object> get props => [route];
}
