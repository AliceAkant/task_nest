import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_nest/infrastructure/routes/app_routes.dart';

part 'bottom_navigation_state.dart';

class BottomNavigationCubit extends Cubit<BottomNavigationState> {
  BottomNavigationCubit()
    : super(const BottomNavigationState(tab: AppRoutes.schedule, index: 0));

  void setNavBarItem(int index) {
    switch (index) {
      case 0:
        emit(const BottomNavigationState(tab: AppRoutes.schedule, index: 0));
        break;
      case 1:
        emit(const BottomNavigationState(tab: AppRoutes.settings, index: 1));
        break;
    }
  }
}
