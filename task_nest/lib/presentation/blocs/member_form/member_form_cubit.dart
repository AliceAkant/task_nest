import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/usecases/members/add_member_usecase.dart';
import 'package:task_nest/domain/usecases/members/delete_member_usecase.dart';
import 'package:task_nest/domain/usecases/members/update_member_usecase.dart';
import 'package:task_nest/infrastructure/di/injection.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/presentation/blocs/base_form/base_form_cubit.dart';
import 'package:task_nest/presentation/enum/form_mode.dart';
import 'package:task_nest/domain/enums/member_theme.dart';
import 'member_form_state.dart';

class MemberFormCubit extends FormCubit<MemberFormState> {
  final AddMemberUseCase _addMemberUC;
  final UpdateMemberUseCase _editMemberUC;
  final DeleteMemberUseCase _deleteMemberUC;

  MemberFormCubit(FormMode mode, Member? initialMember)
    : _addMemberUC = DI.container<AddMemberUseCase>(),
      _editMemberUC = DI.container<UpdateMemberUseCase>(),
      _deleteMemberUC = DI.container<DeleteMemberUseCase>(),
      super(MemberFormState.initial(mode, initialMember));

  ///
  /// CHANGE HANDLERS
  ///

  void nameChanged(String name) =>
      emit(state.copyWith(name: name, isValid: name.isNotEmpty));

  void colorChanged(MemberTheme color) =>
      emit(state.copyWith(memberTheme: color));

  void avatarChanged(Avatar avatar) => emit(state.copyWith(avatar: avatar));

  ///
  /// METHODS
  ///

  Future save() async {
    if (!state.isValid) {
      emit(state.copyWith(validationMode: true));
      return;
    }

    emitLoading();

    if (state.mode == FormMode.add) {
      await _addMember();
    } else {
      await _editMember();
    }
  }

  Future _addMember() async {
    final result = await _addMemberUC.call(
      state.name,
      state.memberTheme,
      state.avatar,
    );

    processUseCaseResult<Member>(result, onSuccess: (_) => emitComplete());
  }

  Future _editMember() async {
    if (state.memberId != null) {
      final member = Member(
        id: state.memberId!,
        name: state.name,
        theme: state.memberTheme,
        avatar: state.avatar,
      );

      final result = await _editMemberUC.call(member);

      processUseCaseResult<Member>(result, onSuccess: (_) => emitComplete());
    } else {
      emitError(null);
    }
  }

  Future delete() async {
    if (state.memberId != null) {
      final result = await _deleteMemberUC.call(state.memberId!);

      processUseCaseResult<bool>(result, onSuccess: (_) => emitComplete());
    } else {
      emitError(null);
    }
  }
}
