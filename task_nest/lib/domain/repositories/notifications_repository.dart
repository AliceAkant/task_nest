import 'package:task_nest/domain/enums/notification_permission_result.dart';
import 'package:task_nest/domain/enums/reminder_offset.dart';

abstract class NotificationsRepository {
  Future<bool> checkPermissions();

  Future<NotificationPermissionResult> requestPermissions();

  Future<void> openSystemSettings();

  Future<void> scheduleEventReminders({
    required int eventId,
    required String eventTitle,
    required DateTime eventDateTime,
    required Set<ReminderOffset> reminders,
    String? memberName,
  });

  /// Cancels all OS-scheduled notifications for an event id.
  Future<void> removeEventReminders(int eventId);

  Future<void> cancelAllNotifications();

  Future<Set<ReminderOffset>> loadEventReminders(int eventId);

  Future<void> saveEventReminders(int eventId, Set<ReminderOffset> reminders);

  Future<void> clearEventReminders(int eventId);
}
