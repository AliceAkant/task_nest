import 'package:task_nest/domain/entities/user_profile.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/presentation/blocs/base_form/base_form_state.dart';
import 'package:task_nest/presentation/enum/schedule_filter_mode.dart';

class ProfileState extends BaseFormState {
  final String userName;
  final Avatar avatar;
  final DefaultScheduleFilterMode scheduleFilterMode;
  final bool validationMode;
  final bool isValid;

  const ProfileState({
    required this.userName,
    required this.avatar,
    required this.scheduleFilterMode,
    required this.validationMode,
    required this.isValid,
    required super.isSaving,
    required super.hasError,
    super.errorMessage,
    super.completed,
  });

  factory ProfileState.initial(UserProfile? user) {
    return ProfileState(
      userName: user?.name ?? '',
      avatar: user?.avatar ?? Avatar.none,
      scheduleFilterMode: (user?.settings.showOnlyMyEvents ?? false)
          ? DefaultScheduleFilterMode.onlyMine
          : DefaultScheduleFilterMode.all,
      validationMode: false,
      isValid: true,
      isSaving: false,
      hasError: false,
      completed: false,
    );
  }

  @override
  ProfileState copyWith({
    String? userName,
    Avatar? avatar,
    DefaultScheduleFilterMode? scheduleFilterMode,
    bool? validationMode,
    bool? isValid,
    bool? isSaving,
    bool? hasError,
    String? errorMessage,
    bool? completed,
  }) {
    return ProfileState(
      userName: userName ?? this.userName,
      avatar: avatar ?? this.avatar,
      scheduleFilterMode: scheduleFilterMode ?? this.scheduleFilterMode,
      validationMode: validationMode ?? this.validationMode,
      isValid: isValid ?? this.isValid,
      isSaving: isSaving ?? this.isSaving,
      hasError: hasError ?? this.hasError,
      completed: completed ?? this.completed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    userName,
    avatar,
    scheduleFilterMode,
    validationMode,
    isValid,
    isSaving,
    hasError,
    errorMessage,
    completed,
  ];
}
