import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';
import 'greeting_state.dart';

class GreetingCubit extends Cubit<GreetingState> {
  final UserCubit _userCubit;

  GreetingCubit(this._userCubit) : super(GreetingState.initial());

  void nameChanged(String name) {
    emit(state.copyWith(name: name, isValid: name.isNotEmpty));
  }

  void avatarChanged(Avatar avatar) {
    emit(state.copyWith(avatar: avatar));
  }

  Future save() async {
    if (!state.isValid) {
      emit(state.copyWith(validationMode: true));
      return;
    }

    emit(state.copyWith(isSaving: true));

    await _userCubit.initializeUser(state.name, state.avatar);

    emit(state.copyWith(isSaving: false, completed: true));
  }
}
