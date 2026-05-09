import 'package:task_nest/domain/entities/notifications_state.dart';
import 'package:task_nest/domain/enums/notification_permission_result.dart';
import 'package:task_nest/domain/enums/reminder_offset.dart';
import 'package:task_nest/domain/repositories/app_preferences_repository.dart';
import 'package:task_nest/domain/repositories/events_repository.dart';
import 'package:task_nest/domain/repositories/notifications_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State & permission
// ─────────────────────────────────────────────────────────────────────────────

class GetNotificationsStateUseCase {
  final NotificationsRepository notifications;
  final AppPreferencesRepository preferences;

  GetNotificationsStateUseCase(this.notifications, this.preferences);

  Future<NotificationsState> call() async {
    final osGranted = await notifications.checkPermissions();
    final muted = await preferences.getNotificationsMuted();
    return NotificationsState(osGranted: osGranted, muted: muted);
  }
}

class RequestNotificationPermissionUseCase {
  final NotificationsRepository repository;

  RequestNotificationPermissionUseCase(this.repository);

  Future<NotificationPermissionResult> call() => repository.requestPermissions();
}

class OpenNotificationSettingsUseCase {
  final NotificationsRepository repository;

  OpenNotificationSettingsUseCase(this.repository);

  Future<void> call() => repository.openSystemSettings();
}

// ─────────────────────────────────────────────────────────────────────────────
// In-app mute
// ─────────────────────────────────────────────────────────────────────────────

/// Single source of truth for the in-app notifications mute toggle.
///
/// * mute=true  → persist + cancel every pending OS notification.
/// * mute=false → persist + re-schedule all future events that have saved
///                reminder offsets, so they fire exactly on time.
class SetNotificationsMutedUseCase {
  final AppPreferencesRepository preferences;
  final NotificationsRepository notifications;
  final EventsRepository events;

  SetNotificationsMutedUseCase(
    this.preferences,
    this.notifications,
    this.events,
  );

  Future<void> call(bool muted) async {
    await preferences.setNotificationsMuted(muted);

    if (muted) {
      await notifications.cancelAllNotifications();
      return;
    }

    final result = await events.getAllEvents();
    await result.fold((_) async {}, (list) async {
      final now = DateTime.now();
      for (final event in list) {
        if (event.id == null) continue;
        if (event.dateTime.isBefore(now)) continue;
        final offsets = await notifications.loadEventReminders(event.id!);
        if (offsets.isEmpty) continue;
        await notifications.scheduleEventReminders(
          eventId: event.id!,
          eventTitle: event.title,
          eventDateTime: event.dateTime,
          reminders: offsets,
          memberName: event.member?.name,
        );
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-event reminders
// ─────────────────────────────────────────────────────────────────────────────

/// Persists reminder offsets for the event and, unless app-level muted,
/// schedules them in the OS so they fire on time.
class ScheduleEventRemindersUseCase {
  final NotificationsRepository notifications;
  final AppPreferencesRepository preferences;

  ScheduleEventRemindersUseCase(this.notifications, this.preferences);

  Future<void> call({
    required int eventId,
    required String eventTitle,
    required DateTime eventDateTime,
    required Set<ReminderOffset> reminders,
    String? memberName,
  }) async {
    await notifications.saveEventReminders(eventId, reminders);

    final muted = await preferences.getNotificationsMuted();
    if (muted) {
      await notifications.removeEventReminders(eventId);
      return;
    }

    await notifications.scheduleEventReminders(
      eventId: eventId,
      eventTitle: eventTitle,
      eventDateTime: eventDateTime,
      reminders: reminders,
      memberName: memberName,
    );
  }
}

class RemoveEventRemindersUseCase {
  final NotificationsRepository repository;

  RemoveEventRemindersUseCase(this.repository);

  Future<void> call(int eventId) async {
    await repository.removeEventReminders(eventId);
    await repository.clearEventReminders(eventId);
  }
}

class LoadEventRemindersUseCase {
  final NotificationsRepository repository;

  LoadEventRemindersUseCase(this.repository);

  Future<Set<ReminderOffset>> call(int eventId) =>
      repository.loadEventReminders(eventId);
}
