import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_nest/domain/enums/notification_permission_result.dart';
import 'package:task_nest/domain/enums/reminder_offset.dart';
import 'package:task_nest/domain/repositories/notifications_repository.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsRepositoryImpl implements NotificationsRepository {
  static const String _channelId = 'task_nest_reminders';
  static const String _channelName = 'Event Reminders';
  static const String _channelDescription =
      'High priority reminders for scheduled events';
  static const String _prefsKeyPrefix = 'event_reminders_';

  /// Daily-brief IDs reserved range: [_dailyBriefIdBase, _dailyBriefIdBase+30).
  /// Won't collide with per-event reminder IDs since event IDs * 10 are
  /// typically much smaller and the offset is large.
  static const int _dailyBriefIdBase = 2000000000;
  static const int _dailyBriefMaxDays = 14;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );
  }

  @override
  Future<bool> checkPermissions() async {
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final settings = await ios?.checkPermissions();
      if (settings == null) return false;
      return settings.isEnabled;
    }
    final status = await Permission.notification.status;
    return status.isGranted || status.isProvisional;
  }

  /// Show the OS dialog if permission is undetermined. Never opens OS Settings.
  /// Callers handle "denied" by routing the user to settings themselves.
  @override
  Future<NotificationPermissionResult> requestPermissions() async {
    if (await checkPermissions()) {
      await _ensureExactAlarmsPermissionAndroid();
      return NotificationPermissionResult.granted;
    }

    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isPermanentlyDenied) {
        return NotificationPermissionResult.permanentlyDenied;
      }
    }

    final granted = await _platformRequestPermission();
    if (granted) {
      await _ensureExactAlarmsPermissionAndroid();
      return NotificationPermissionResult.granted;
    }

    if (Platform.isAndroid) {
      final after = await Permission.notification.status;
      if (after.isPermanentlyDenied) {
        return NotificationPermissionResult.permanentlyDenied;
      }
    }
    return NotificationPermissionResult.denied;
  }

  @override
  Future<void> openSystemSettings() =>
      AppSettings.openAppSettings(type: AppSettingsType.notification);

  @override
  Future<void> scheduleEventReminders({
    required int eventId,
    required String eventTitle,
    required DateTime eventDateTime,
    required Set<ReminderOffset> reminders,
    String? memberName,
  }) async {
    await removeEventReminders(eventId);

    if (reminders.isEmpty) return;

    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(eventDateTime);
    final bodyBase = tr(
      LocaleKeys.notification_scheduled_at,
      namedArgs: {'time': timeStr},
    );
    final body = memberName != null
        ? '$bodyBase\n${tr(LocaleKeys.member_name_show, namedArgs: {'name': memberName})}'
        : bodyBase;

    for (final reminder in reminders) {
      final notifyAt = eventDateTime.subtract(reminder.duration);
      if (notifyAt.isAfter(now)) {
        await _scheduleNotification(
          id: _notificationId(eventId, reminder),
          title: eventTitle,
          body: body,
          scheduledDate: notifyAt,
        );
      }
    }
  }

  @override
  Future<void> removeEventReminders(int eventId) async {
    for (final reminder in ReminderOffset.values) {
      await _plugin.cancel(_notificationId(eventId, reminder));
    }
  }

  @override
  Future<void> cancelAllNotifications() => _plugin.cancelAll();

  @override
  Future<void> saveEventReminders(
    int eventId,
    Set<ReminderOffset> reminders,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final indices = reminders.map((r) => r.index).toList();
    await prefs.setString('$_prefsKeyPrefix$eventId', jsonEncode(indices));
  }

  @override
  Future<Set<ReminderOffset>> loadEventReminders(int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefsKeyPrefix$eventId');
    if (raw == null) return {};
    final List<dynamic> indices = jsonDecode(raw);
    return indices
        .whereType<int>()
        .where((i) => i >= 0 && i < ReminderOffset.values.length)
        .map((i) => ReminderOffset.values[i])
        .toSet();
  }

  @override
  Future<void> clearEventReminders(int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefsKeyPrefix$eventId');
  }

  // ──────────────────────────────────────────────────────────────────────────

  /// On iOS go through flutter_local_notifications (UNUserNotificationCenter
  /// directly) — this reliably triggers the system prompt the first time.
  /// On Android use permission_handler.
  Future<bool> _platformRequestPermission() async {
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    final result = await Permission.notification.request();
    return result.isGranted || result.isProvisional;
  }

  Future<void> _ensureExactAlarmsPermissionAndroid() async {
    if (!Platform.isAndroid) return;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestExactAlarmsPermission();
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          icon: '@drawable/ic_notification',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          fullScreenIntent: false,
          // Категория alarm позволяет пробиться через DND/тихий режим
          category: AndroidNotificationCategory.alarm,
          // BigTextStyle чтобы длинный body (с именем участника) не обрезался
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          // timeSensitive пробивает Focus-режимы (iOS 15+), не требует entitlement
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  int _notificationId(int eventId, ReminderOffset reminder) =>
      (eventId * 10 + reminder.index) % 2147483647;

  @override
  Future<void> scheduleDailyBrief({
    required int dayId,
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) async {
    if (dayId < 0 || dayId >= _dailyBriefMaxDays) return;
    if (!scheduledAt.isAfter(DateTime.now())) return;
    final id = (_dailyBriefIdBase + dayId) % 2147483647;
    await _plugin.cancel(id);
    await _scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledAt,
    );
  }

  @override
  Future<void> cancelAllDailyBriefs() async {
    for (var i = 0; i < _dailyBriefMaxDays; i++) {
      final id = (_dailyBriefIdBase + i) % 2147483647;
      await _plugin.cancel(id);
    }
  }
}
