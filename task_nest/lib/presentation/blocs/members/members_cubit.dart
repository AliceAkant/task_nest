import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/usecases/members_use_cases.dart';
import 'package:task_nest/infrastructure/di/injection.dart';

part 'members_state.dart';

class MembersCubit extends Cubit<MembersState> {
  final GetMembersUseCase _getMembers;

  MembersCubit()
    : _getMembers = DI.container<GetMembersUseCase>(),
      super(MembersInitial());

  Future loadData() async {
    emit(Loading());

    final result = await _getMembers.call();

    result.fold(
      (failure) => emit(LoadError()),
      (savedMember) => emit(DataLoaded(savedMember)),
    );
  }
}
