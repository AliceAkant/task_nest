import 'package:easy_localization/easy_localization.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/entities/notifications_state.dart';
import 'package:task_nest/domain/enums/notification_permission_result.dart';
import 'package:task_nest/domain/enums/reminder_offset.dart';
import 'package:task_nest/domain/repositories/app_preferences_repository.dart';
import 'package:task_nest/domain/repositories/events_repository.dart';
import 'package:task_nest/domain/repositories/notifications_repository.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';

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

// ─────────────────────────────────────────────────────────────────────────────
// Daily brief
// ─────────────────────────────────────────────────────────────────────────────

/// Cancels all scheduled daily briefs and re-schedules the next ~7 days
/// individually. Each day's body is computed from that day's events at
/// scheduling time, so briefs reflect the latest plan as long as the app is
/// opened (or any event is mutated) at least once a week.
///
/// Skipped silently if disabled, OS-denied, or app-muted.
class RescheduleDailyBriefUseCase {
  static const int _daysAhead = 7;
  static const int _maxLines = 5;

  final NotificationsRepository notifications;
  final AppPreferencesRepository preferences;
  final EventsRepository events;

  RescheduleDailyBriefUseCase(
    this.notifications,
    this.preferences,
    this.events,
  );

  Future<void> call() async {
    await notifications.cancelAllDailyBriefs();

    final settings = await preferences.getDailyBriefSettings();
    if (!settings.enabled) return;

    final muted = await preferences.getNotificationsMuted();
    if (muted) return;

    final osGranted = await notifications.checkPermissions();
    if (!osGranted) return;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final endExclusive = start.add(const Duration(days: _daysAhead));

    final result =
        await events.getEventsBetween(start, endExclusive.subtract(const Duration(seconds: 1)));
    final list = result.fold<List<Event>>((_) => const [], (l) => l);

    final byDay = <DateTime, List<Event>>{};
    for (final ev in list) {
      final key = DateTime(
        ev.dateTime.year,
        ev.dateTime.month,
        ev.dateTime.day,
      );
      (byDay[key] ??= []).add(ev);
    }

    for (var i = 0; i < _daysAhead; i++) {
      final day = start.add(Duration(days: i));
      final scheduledAt = DateTime(
        day.year,
        day.month,
        day.day,
        settings.hour,
        settings.minute,
      );
      if (!scheduledAt.isAfter(now)) continue;

      final dayEvents = byDay[day] ?? const <Event>[];
      final sorted = [...dayEvents]
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

      final isToday = i == 0;
      final title = tr(isToday
          ? LocaleKeys.daily_brief_title_today
          : LocaleKeys.daily_brief_title_tomorrow);
      final body = _buildBody(sorted);

      await notifications.scheduleDailyBrief(
        dayId: i,
        scheduledAt: scheduledAt,
        title: title,
        body: body,
      );
    }
  }

  String _buildBody(List<Event> sorted) {
    if (sorted.isEmpty) return tr(LocaleKeys.daily_brief_body_empty);

    final header = tr(
      LocaleKeys.daily_brief_body_count,
      namedArgs: {'count': sorted.length.toString()},
    );

    final lines = <String>[header];
    for (var i = 0; i < sorted.length && i < _maxLines; i++) {
      final ev = sorted[i];
      final hh = ev.dateTime.hour.toString().padLeft(2, '0');
      final mm = ev.dateTime.minute.toString().padLeft(2, '0');
      lines.add(tr(
        LocaleKeys.daily_brief_event_line,
        namedArgs: {'time': '$hh:$mm', 'title': ev.title},
      ));
    }
    if (sorted.length > _maxLines) {
      lines.add('…');
    }
    return lines.join('\n');
  }
}
