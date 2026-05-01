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
import 'package:task_nest/presentation/enum/schedule_view_mode.dart';
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
    switch (state.viewMode) {
      case ScheduleViewMode.week:
        await loadWeek();
      case ScheduleViewMode.month:
        if (state.selectedDate != null) {
          await loadByDate(state.selectedDate!);
        }
      case ScheduleViewMode.day:
        if (state.dateFilterMode == DateFilterMode.dateFilter &&
            state.selectedDate != null) {
          await loadByDate(state.selectedDate!);
        } else {
          await loadMainSchedule();
        }
    }
  }

  void setViewMode(ScheduleViewMode mode) {
    if (state.viewMode == mode) return;
    switch (mode) {
      case ScheduleViewMode.day:
        emit(state.copyWith(viewMode: mode));
        loadMainSchedule();
      case ScheduleViewMode.week:
        emit(state.copyWith(viewMode: mode));
        loadWeek();
      case ScheduleViewMode.month:
        emit(state.copyWith(
          viewMode: mode,
          dateFilterMode: DateFilterMode.main,
          rawEvents: {},
          filteredEvents: {},
          isLoading: false,
          clearError: true,
        ));
    }
  }

  /// Загружает сегодня и завтра
  Future loadMainSchedule() async {
    final today = DateTime.now().dateOnly;
    final tomorrow = today.add(const Duration(days: 1));

    emit(
      state.copyWith(
        isLoading: true,
        dateFilterMode: DateFilterMode.main,
        selectedDate: null,
        clearError: true,
      ),
    );

    // tomorrow передаём как end, DataSource добавит endOfDay -> 23:59 завтра
    final result = await _getEventsBetweenDate.call(today, tomorrow);

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

  /// Загружает 7 дней начиная с сегодня
  Future loadWeek() async {
    final today = DateTime.now().dateOnly;
    final end = today.add(const Duration(days: 6));

    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
      ),
    );

    final result = await _getEventsBetweenDate.call(today, end);

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
          for (var i = 0; i <= 6; i++)
            today.add(Duration(days: i)):
                map[today.add(Duration(days: i))] ?? [],
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

  /// Загружает события на конкретную дату
  Future loadByDate(DateTime date) async {
    final dateFilter = date.dateOnly;

    emit(
      state.copyWith(
        isLoading: true,
        dateFilterMode: DateFilterMode.dateFilter,
        selectedDate: dateFilter,
        clearError: true,
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
        clearError: true,
      ),
    );
    updateState();
  }

  void filterBy({
    DateTime? date,
    Member? member,
    required MemberFilterMode memberFilterMode,
  }) {
    final resolvedMember =
        memberFilterMode == MemberFilterMode.member ? member : null;

    if (date != null) {
      emit(
        state.copyWith(
          memberFilterMode: memberFilterMode,
          selectedMember: resolvedMember,
        ),
      );
      loadByDate(date);
      return;
    }

    final needResetDate =
        state.dateFilterMode == DateFilterMode.dateFilter &&
        state.selectedDate != null;

    if (needResetDate) {
      // Сначала обновляем фильтр участника, потом грузим данные заново
      emit(
        state.copyWith(
          memberFilterMode: memberFilterMode,
          selectedMember: resolvedMember,
        ),
      );
      loadMainSchedule();
    } else {
      // Данные уже загружены, только применяем фильтр - один emit
      final filtered = _applyMemberFilter(
        state.rawEvents,
        memberFilterMode,
        member,
      );
      emit(
        state.copyWith(
          memberFilterMode: memberFilterMode,
          selectedMember: resolvedMember,
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
