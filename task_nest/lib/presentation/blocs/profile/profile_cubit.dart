import 'package:task_nest/domain/entities/user_profile.dart';
import 'package:task_nest/domain/entities/user_settings.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/presentation/blocs/base_form/base_form_cubit.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';
import 'package:task_nest/presentation/enum/schedule_filter_mode.dart';
import 'profile_state.dart';

class ProfileCubit extends FormCubit<ProfileState> {
  final UserCubit _userCubit;

  ProfileCubit({required UserCubit userCubit})
    : _userCubit = userCubit,
      super(ProfileState.initial(userCubit.state));

  ///
  /// CHANGE HANDLERS
  ///

  void nameChanged(String name) =>
      emit(state.copyWith(userName: name, isValid: name.isNotEmpty));

  void avatarChanged(Avatar avatar) => emit(state.copyWith(avatar: avatar));

  void scheduleModeChanged(DefaultScheduleFilterMode mode) =>
      emit(state.copyWith(scheduleFilterMode: mode));

  ///
  /// METHODS
  ///

  Future save() async {
    if (state.userName.isEmpty) {
      emit(state.copyWith(isValid: false, validationMode: true));
      return;
    }

    emitLoading();

    final user = UserProfile(
      name: state.userName,
      avatar: state.avatar,
      settings: UserSettings(
        showOnlyMyEvents:
            state.scheduleFilterMode == DefaultScheduleFilterMode.onlyMine,
      ),
    );

    final result = await _userCubit.update(user);

    processUseCaseResult<bool>(result, onSuccess: (_) => emitComplete());
  }
}
