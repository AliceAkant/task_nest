import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/usecases/events/get_events_between_date_usecase.dart';
import 'package:task_nest/domain/usecases/events/get_events_by_date_usecase.dart';
import 'package:task_nest/infrastructure/di/injection.dart';
import 'package:equatable/equatable.dart';
import 'package:task_nest/presentation/blocs/members/members_cubit.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';
import 'package:task_nest/presentation/enum/date_filter_mode.dart';
import 'package:task_nest/presentation/enum/member_filter_mode.dart';
import 'package:task_nest/presentation/extensions/date_time_extension.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final GetEventsBetweenDateUseCase _getEventsBetweenDate;
  final GetEventsByDateUseCase _getEventsByDate;

  late final StreamSubscription _membersSubscription;

  ScheduleCubit({
    required UserCubit userCubit,
    required MembersCubit membersCubit,
  }) : _getEventsBetweenDate = DI.container<GetEventsBetweenDateUseCase>(),
       _getEventsByDate = DI.container<GetEventsByDateUseCase>(),
       super(
         ScheduleState.initial(
           onlyMineDefault: userCubit.state?.settings.showOnlyMyEvents ?? false,
         ),
       ) {
    _initialize();
    _subscribeOnMembers(membersCubit);
  }

  Future _initialize() async {
    await loadMainSchedule();
  }

  void _subscribeOnMembers(MembersCubit membersCubit) {
    _membersSubscription = membersCubit.stream.listen((membersState) {
      if (membersState is DataLoaded) {
        _onMembersChanged(membersState.members);
      }
    });
  }

  @override
  Future close() {
    _membersSubscription.cancel();
    return super.close();
  }

  void tabOpened() => updateState();

  Future updateState() async {
    if (state.dateFilterMode == DateFilterMode.dateFilter &&
        state.selectedDate != null) {
      await loadByDate(state.selectedDate!);
    } else {
      await loadMainSchedule();
    }
  }

  /// Load main schedule: today & tomorrow
  Future loadMainSchedule() async {
    final today = DateTime.now().dateOnly;
    final tomorrow = today.add(const Duration(days: 1));
    final endTomorrow = today.add(const Duration(days: 2));

    emit(
      state.copyWith(
        isLoading: true,
        dateFilterMode: DateFilterMode.main,
        selectedDate: null,
        error: null,
      ),
    );

    final result = await _getEventsBetweenDate.call(today, endTomorrow);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          hasError: true,
          error: failure.message,
        ),
      ),
      (events) {
        final map = groupBy(events, (Event e) => e.dateTime.dateOnly);

        final raw = <DateTime, List<Event>>{
          today: map[today] ?? <Event>[],
          tomorrow: map[tomorrow] ?? <Event>[],
        };

        final filtered = _applyMemberFilter(
          raw,
          state.memberFilterMode,
          state.selectedMember,
        );

        emit(
          state.copyWith(
            isLoading: false,
            hasError: false,
            rawEvents: raw,
            filteredEvents: filtered,
          ),
        );
      },
    );
  }

  /// Load schedule for a single date
  Future loadByDate(DateTime date) async {
    final dateFilter = date.dateOnly;

    emit(
      state.copyWith(
        isLoading: true,
        dateFilterMode: DateFilterMode.dateFilter,
        selectedDate: dateFilter,
        error: null,
      ),
    );

    final result = await _getEventsByDate.call(dateFilter);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          hasError: true,
          error: failure.message,
        ),
      ),
      (events) {
        final raw = <DateTime, List<Event>>{dateFilter: events};

        final filtered = _applyMemberFilter(
          raw,
          state.memberFilterMode,
          state.selectedMember,
        );

        emit(
          state.copyWith(
            isLoading: false,
            hasError: false,
            rawEvents: raw,
            filteredEvents: filtered,
          ),
        );
      },
    );
  }

  ///
  /// Filters
  ///

  void resetAllFilters() {
    emit(
      state.copyWith(
        dateFilterMode: DateFilterMode.main,
        selectedDate: null,
        memberFilterMode: MemberFilterMode.all,
        selectedMember: null,
      ),
    );
    loadMainSchedule();
  }

  void resetMemberFilter() {
    final filtered = _applyMemberFilter(
      state.rawEvents,
      MemberFilterMode.all,
      null,
    );
    emit(
      state.copyWith(
        memberFilterMode: MemberFilterMode.all,
        selectedMember: null,
        filteredEvents: filtered,
      ),
    );
  }

  void resetDateFilter() {
    emit(
      state.copyWith(
        dateFilterMode: DateFilterMode.main,
        selectedDate: null,
        error: null,
      ),
    );
    updateState();
  }

  void filterBy({
    DateTime? date,
    Member? member,
    required MemberFilterMode memberFilterMode,
  }) {
    if (date != null) {
      emit(
        state.copyWith(
          memberFilterMode: memberFilterMode,
          selectedMember: memberFilterMode == MemberFilterMode.member
              ? member
              : null,
        ),
      );
      loadByDate(date);
    } else {
      final filtered = _applyMemberFilter(
        state.rawEvents,
        memberFilterMode,
        member,
      );
      emit(
        state.copyWith(
          memberFilterMode: memberFilterMode,
          selectedMember: memberFilterMode == MemberFilterMode.member
              ? member
              : null,
          filteredEvents: filtered,
        ),
      );
    }
  }

  ///
  /// Helpers
  ///

  void _onMembersChanged(List<Member> currentMembers) {
    final selected = state.selectedMember;

    if (state.memberFilterMode == MemberFilterMode.member &&
        selected != null &&
        !currentMembers.any((m) => m.id == selected.id)) {
      resetMemberFilter();
    }
  }

  Map<DateTime, List<Event>> _applyMemberFilter(
    Map<DateTime, List<Event>> source,
    MemberFilterMode mode,
    Member? selectedMember,
  ) {
    switch (mode) {
      case MemberFilterMode.all:
        return source;

      case MemberFilterMode.mine:
        return source.map(
          (date, list) =>
              MapEntry(date, list.where((e) => e.member == null).toList()),
        );

      case MemberFilterMode.member:
        if (selectedMember == null) {
          return source;
        }
        return source.map(
          (date, list) => MapEntry(
            date,
            list.where((e) => e.member?.id == selectedMember.id).toList(),
          ),
        );
    }
  }
}
