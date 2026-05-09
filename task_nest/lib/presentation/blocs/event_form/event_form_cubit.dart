import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/enums/reminder_offset.dart';
import 'package:task_nest/domain/usecases/events_use_cases.dart';
import 'package:task_nest/domain/usecases/notifications_use_cases.dart';
import 'package:task_nest/infrastructure/di/injection.dart';
import 'package:task_nest/presentation/blocs/base_form/base_form_cubit.dart';
import 'package:task_nest/presentation/enum/form_mode.dart';
import 'package:task_nest/core/extensions/date_time_extension.dart';
import 'event_form_state.dart';

class EventFormCubit extends FormCubit<EventFormState> {
  final AddEventUseCase _addEventUC;
  final UpdateEventUseCase _editEventUC;
  final DeleteEventUseCase _deleteEventUC;
  final ScheduleEventRemindersUseCase _scheduleRemindersUC;
  final RemoveEventRemindersUseCase _removeRemindersUC;
  final LoadEventRemindersUseCase _loadRemindersUC;
  final GetNotificationsStateUseCase _getNotificationsStateUC;
  final SetNotificationsMutedUseCase _setMutedUC;
  final OpenNotificationSettingsUseCase _openSettingsUC;

  Future<void>? _remindersLoading;

  EventFormCubit(FormMode mode, Event? initialEvent, DateTime? initialDate)
    : _addEventUC = DI.container<AddEventUseCase>(),
      _editEventUC = DI.container<UpdateEventUseCase>(),
      _deleteEventUC = DI.container<DeleteEventUseCase>(),
      _scheduleRemindersUC = DI.container<ScheduleEventRemindersUseCase>(),
      _removeRemindersUC = DI.container<RemoveEventRemindersUseCase>(),
      _loadRemindersUC = DI.container<LoadEventRemindersUseCase>(),
      _getNotificationsStateUC =
          DI.container<GetNotificationsStateUseCase>(),
      _setMutedUC = DI.container<SetNotificationsMutedUseCase>(),
      _openSettingsUC = DI.container<OpenNotificationSettingsUseCase>(),
      super(
        EventFormState.initial(mode, initialEvent, _getCustomTime(initialDate)),
      ) {
    if (initialEvent?.id != null) {
      _remindersLoading = _loadReminders(initialEvent!.id!);
    }
    refreshPermission();
  }

  Future<void> _loadReminders(int eventId) async {
    final reminders = await _loadRemindersUC.call(eventId);
    emit(state.copyWith(reminders: reminders));
  }

  Future<void> refreshPermission() async {
    final s = await _getNotificationsStateUC.call();
    if (state.osPermissionGranted != s.osGranted ||
        state.notificationsMuted != s.muted) {
      emit(state.copyWith(
        osPermissionGranted: s.osGranted,
        notificationsMuted: s.muted,
      ));
    }
  }

  Future<void> openNotificationSettings() async {
    await _openSettingsUC.call();
  }

  ///
  /// CHANGE HANDLERS
  ///

  void titleChanged(String title) =>
      emit(state.copyWith(title: title, isTitleValid: title.isNotEmpty));

  void assignToMeChanged(bool assignToMe) =>
      emit(state.copyWith(assignToMe: assignToMe));

  void dateChanged(int year, int month, int day) => emit(
    state.copyWith(
      date: state.date.copyWith(year: year, month: month, day: day),
    ),
  );

  void timeChanged(int hour, int minute) => emit(
    state.copyWith(
      date: state.date.copyWith(hour: hour, minute: minute),
    ),
  );

  void notesChanged(String note) => emit(state.copyWith(note: note));

  void memberChanged(Member member) =>
      emit(state.copyWith(assignedMember: member));

  void clearReminders() => emit(state.copyWith(reminders: {}));

  /// Tapping a reminder offset:
  /// * OS denied → caller (dropdown) routes tap to openNotificationSettings.
  ///   This method should not be called in that case.
  /// * Locally muted → silently auto-unmute, then add to state.
  /// * Active → just toggle.
  Future<void> reminderToggled(ReminderOffset reminder) async {
    if (!state.osPermissionGranted) return;

    final isAdding = !state.reminders.contains(reminder);
    if (isAdding && state.notificationsMuted) {
      await _setMutedUC.call(false);
      emit(state.copyWith(notificationsMuted: false));
    }

    final current = Set<ReminderOffset>.from(state.reminders);
    if (current.contains(reminder)) {
      current.remove(reminder);
    } else {
      current.add(reminder);
    }
    emit(state.copyWith(reminders: current));
  }

  ///
  /// METHODS
  ///

  Future save() async {
    if (state.title.isEmpty) {
      emit(state.copyWith(isTitleValid: false, validationMode: true));
      return;
    }

    emitLoading();

    if (state.mode == FormMode.add) {
      await _addEvent();
    } else {
      await _editEvent();
    }
  }

  Future _addEvent() async {
    final event = Event(
      id: null,
      title: state.title,
      dateTime: state.date,
      member: state.assignToMe ? null : state.assignedMember,
      notes: state.note,
    );
    final result = await _addEventUC.call(event);

    processUseCaseResult<Event>(
      result,
      onSuccess: (savedEvent) async {
        if (savedEvent.id != null && state.reminders.isNotEmpty) {
          await _scheduleReminders(savedEvent.id!, savedEvent.title);
        }
        emitComplete();
      },
    );
  }

  Future _editEvent() async {
    if (state.eventId != null) {
      // Wait for existing reminders to load so we don't overwrite them with empty.
      await _remindersLoading;

      final event = Event(
        id: state.eventId,
        title: state.title,
        dateTime: state.date,
        member: state.assignToMe ? null : state.assignedMember,
        notes: state.note,
      );

      final result = await _editEventUC.call(event);

      processUseCaseResult<Event>(
        result,
        onSuccess: (updatedEvent) async {
          await _scheduleReminders(state.eventId!, updatedEvent.title);
          emitComplete();
        },
      );
    } else {
      emitError(null);
    }
  }

  Future delete() async {
    if (state.eventId != null) {
      final result = await _deleteEventUC.call(state.eventId!);

      processUseCaseResult<bool>(
        result,
        onSuccess: (_) async {
          await _removeRemindersUC.call(state.eventId!);
          emitComplete();
        },
      );
    } else {
      emitError(null);
    }
  }

  Future<void> _scheduleReminders(int eventId, String eventTitle) async {
    await _scheduleRemindersUC.call(
      eventId: eventId,
      eventTitle: eventTitle,
      eventDateTime: state.date,
      reminders: state.reminders,
      memberName: state.assignedMember?.name,
    );
  }

  static DateTime _getCustomTime(DateTime? initialDate) {
    if (initialDate != null) {
      return initialDate.add(Duration(hours: 12));
    }

    final now = DateTime.now();
    final endOfDay = now.endOfDay;

    if (endOfDay.difference(now).inHours < 2) {
      final roundedMinutes = ((now.minute + 9) ~/ 10) * 10;
      if (roundedMinutes >= 60) {
        return DateTime(now.year, now.month, now.day, now.hour + 1, 0);
      }
      return DateTime(now.year, now.month, now.day, now.hour, roundedMinutes);
    }
    return DateTime(now.year, now.month, now.day, now.hour + 2, 0);
  }
}
