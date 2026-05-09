import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/enums/reminder_offset.dart';
import 'package:task_nest/presentation/blocs/base_form/base_form_state.dart';
import 'package:task_nest/presentation/enum/form_mode.dart';
import 'package:task_nest/core/extensions/date_time_extension.dart';

class EventFormState extends BaseFormState {
  final FormMode mode;
  final int? eventId;
  final String title;
  final String note;
  final DateTime date;
  final bool assignToMe;
  final Member? assignedMember;
  final bool validationMode;
  final bool isTitleValid;
  final Set<ReminderOffset> reminders;
  final bool osPermissionGranted;
  final bool notificationsMuted;

  const EventFormState({
    required this.mode,
    this.eventId,
    required this.title,
    required this.note,
    required this.date,
    required this.assignToMe,
    required this.assignedMember,
    required this.validationMode,
    required this.isTitleValid,
    required this.reminders,
    required this.osPermissionGranted,
    required this.notificationsMuted,

    required super.isSaving,
    required super.hasError,
    super.errorMessage,
    super.completed,
  });

  factory EventFormState.initial(
    FormMode mode,
    Event? initialEvent,
    DateTime? initialDate,
  ) {
    return EventFormState(
      mode: mode,
      eventId: initialEvent?.id,
      title: initialEvent?.title ?? '',
      note: initialEvent?.notes ?? '',
      date:
          initialEvent?.dateTime ??
          initialDate ??
          DateTime.now().dateOnly.add(Duration(hours: 12)),
      assignToMe: initialEvent?.member == null,
      assignedMember: initialEvent?.member,
      validationMode: false,
      isTitleValid: true,
      reminders: const {},
      osPermissionGranted: false,
      notificationsMuted: false,
      isSaving: false,
      hasError: false,
      completed: false,
    );
  }

  @override
  EventFormState copyWith({
    int? eventId,
    String? title,
    String? note,
    DateTime? date,
    bool? assignToMe,
    Member? assignedMember,
    bool? validationMode,
    bool? isTitleValid,
    Set<ReminderOffset>? reminders,
    bool? osPermissionGranted,
    bool? notificationsMuted,

    bool? isSaving,
    bool? hasError,
    bool? completed,
    String? errorMessage,
  }) {
    return EventFormState(
      mode: mode,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      note: note ?? this.note,
      date: date ?? this.date,
      assignToMe: assignToMe ?? this.assignToMe,
      assignedMember: (assignToMe ?? this.assignToMe)
          ? null
          : (assignedMember ?? this.assignedMember),
      validationMode: validationMode ?? this.validationMode,
      isTitleValid: isTitleValid ?? this.isTitleValid,
      reminders: reminders ?? this.reminders,
      osPermissionGranted:
          osPermissionGranted ?? this.osPermissionGranted,
      notificationsMuted: notificationsMuted ?? this.notificationsMuted,

      isSaving: isSaving ?? this.isSaving,
      completed: completed ?? this.completed,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    eventId,
    title,
    note,
    date,
    assignToMe,
    assignedMember,
    validationMode,
    isTitleValid,
    reminders,
    osPermissionGranted,
    notificationsMuted,
    isSaving,
    hasError,
    completed,
    errorMessage,
  ];
}
