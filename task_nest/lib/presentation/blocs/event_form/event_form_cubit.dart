import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/enums/reminder_offset.dart';
import 'package:task_nest/domain/usecases/events/add_event_usecase.dart';
import 'package:task_nest/domain/usecases/events/delete_event_usecase.dart';
import 'package:task_nest/domain/usecases/events/update_event_usecase.dart';
import 'package:task_nest/infrastructure/di/injection.dart';
import 'package:task_nest/infrastructure/notifications/notification_service.dart';
import 'package:task_nest/presentation/blocs/base_form/base_form_cubit.dart';
import 'package:task_nest/presentation/enum/form_mode.dart';
import 'package:task_nest/presentation/extensions/date_time_extension.dart';
import 'event_form_state.dart';

class EventFormCubit extends FormCubit<EventFormState> {
  final AddEventUseCase _addEventUC;
  final UpdateEventUseCase _editEventUC;
  final DeleteEventUseCase _deleteEventUC;
  final NotificationService _notificationService;

  bool _remindersLoaded = false;

  EventFormCubit(FormMode mode, Event? initialEvent, DateTime? initialDate)
    : _addEventUC = DI.container<AddEventUseCase>(),
      _editEventUC = DI.container<UpdateEventUseCase>(),
      _deleteEventUC = DI.container<DeleteEventUseCase>(),
      _notificationService = DI.container<NotificationService>(),
      super(
        EventFormState.initial(mode, initialEvent, _getCustomTime(initialDate)),
      ) {
    if (initialEvent?.id != null) {
      _loadReminders(initialEvent!.id!);
    } else {
      _remindersLoaded = true;
    }
  }

  Future<void> _loadReminders(int eventId) async {
    final reminders = await _notificationService.loadEventReminders(eventId);
    _remindersLoaded = true;
    emit(state.copyWith(reminders: reminders));
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

  Future<void> reminderToggled(ReminderOffset reminder) async {
    final isAdding = !state.reminders.contains(reminder);
    if (isAdding) {
      await _notificationService.requestPermissions();
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
    final result = await _addEventUC.call(
      state.title,
      state.date,
      state.assignToMe ? null : state.assignedMember,
      state.note,
    );

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
          if (_remindersLoaded) {
            await _scheduleReminders(state.eventId!, updatedEvent.title);
          }
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
          await _notificationService.cancelEventReminders(state.eventId!);
          await _notificationService.clearEventReminders(state.eventId!);
          emitComplete();
        },
      );
    } else {
      emitError(null);
    }
  }

  Future<void> _scheduleReminders(int eventId, String eventTitle) async {
    await _notificationService.scheduleEventReminders(
      eventId: eventId,
      eventTitle: eventTitle,
      eventDateTime: state.date,
      reminders: state.reminders,
      memberName: state.assignedMember?.name,
    );
    await _notificationService.saveEventReminders(eventId, state.reminders);
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
