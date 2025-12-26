part of 'schedule_cubit.dart';

class ScheduleState extends Equatable {
  final DateTime? selectedDate;
  final DateFilterMode dateFilterMode;
  final Member? selectedMember;
  final MemberFilterMode memberFilterMode;
  final Map<DateTime, List<Event>> rawEvents;
  final Map<DateTime, List<Event>> filteredEvents;
  final bool isLoading;
  final bool hasError;
  final String? error;

  const ScheduleState({
    required this.selectedDate,
    required this.dateFilterMode,
    required this.selectedMember,
    required this.memberFilterMode,
    required this.rawEvents,
    required this.filteredEvents,
    required this.isLoading,
    required this.hasError,
    this.error,
  });

  factory ScheduleState.initial({bool onlyMineDefault = false}) {
    return ScheduleState(
      selectedDate: null,
      dateFilterMode: DateFilterMode.main,
      selectedMember: null,
      memberFilterMode: onlyMineDefault
          ? MemberFilterMode.mine
          : MemberFilterMode.all,
      rawEvents: const {},
      filteredEvents: const {},
      isLoading: true,
      hasError: false,
      error: null,
    );
  }

  ScheduleState copyWith({
    DateTime? selectedDate,
    DateFilterMode? dateFilterMode,
    Member? selectedMember,
    MemberFilterMode? memberFilterMode,
    Map<DateTime, List<Event>>? rawEvents,
    Map<DateTime, List<Event>>? filteredEvents,
    bool? isLoading,
    bool? hasError,
    String? error,
  }) {
    final mFilterMode = memberFilterMode ?? this.memberFilterMode;
    final dFilterMode = dateFilterMode ?? this.dateFilterMode;
    return ScheduleState(
      selectedDate: dFilterMode == DateFilterMode.dateFilter
          ? (selectedDate ?? this.selectedDate)
          : null,
      dateFilterMode: dFilterMode,
      selectedMember: mFilterMode == MemberFilterMode.member
          ? (selectedMember ?? this.selectedMember)
          : null,
      memberFilterMode: mFilterMode,
      rawEvents: rawEvents ?? this.rawEvents,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    selectedDate,
    dateFilterMode,
    selectedMember,
    memberFilterMode,
    rawEvents,
    filteredEvents,
    isLoading,
    hasError,
    error,
  ];
}
