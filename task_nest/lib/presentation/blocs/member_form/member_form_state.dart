import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/presentation/blocs/base_form/base_form_state.dart';
import 'package:task_nest/presentation/enum/form_mode.dart';
import 'package:task_nest/domain/enums/member_theme.dart';

class MemberFormState extends FormState {
  final FormMode mode;
  final int? memberId;
  final String name;
  final MemberTheme memberTheme;
  final Avatar avatar;
  final bool validationMode;
  final bool isValid;

  const MemberFormState({
    required this.mode,
    this.memberId,
    required this.name,
    required this.memberTheme,
    required this.avatar,
    required this.validationMode,
    required this.isValid,
    required super.isSaving,
    required super.hasError,

    super.completed,
    super.errorMessage,
  });

  factory MemberFormState.initial(FormMode mode, Member? initialMember) {
    return MemberFormState(
      mode: mode,
      memberId: initialMember?.id,
      name: initialMember?.name ?? '',
      memberTheme: initialMember?.theme ?? MemberTheme.none,
      avatar: initialMember?.avatar ?? Avatar.none,
      validationMode: false,
      isValid: initialMember?.name.isNotEmpty ?? false,
      hasError: false,
      isSaving: false,
      completed: false,
    );
  }

  @override
  MemberFormState copyWith({
    int? memberId,
    String? name,
    MemberTheme? memberTheme,
    Avatar? avatar,
    bool? validationMode,
    bool? isValid,
    bool? isSaving,
    String? errorMessage,
    bool? hasError,
    bool? completed,
  }) {
    return MemberFormState(
      memberId: memberId ?? this.memberId,
      mode: mode,
      name: name ?? this.name,
      memberTheme: memberTheme ?? this.memberTheme,
      avatar: avatar ?? this.avatar,
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
    memberId,
    name,
    memberTheme,
    avatar,
    validationMode,
    isValid,
    isSaving,
    errorMessage,
    hasError,
    mode,
    completed,
  ];
}
