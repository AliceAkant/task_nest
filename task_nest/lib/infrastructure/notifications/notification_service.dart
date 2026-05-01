import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_nest/domain/enums/reminder_offset.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const String _channelId = 'task_nest_reminders';
  static const String _channelName = 'Event Reminders';
  static const String _channelDescription = 'High priority reminders for scheduled events';
  static const String _prefsKeyPrefix = 'event_reminders_';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final String localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
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

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted =
          await android.requestNotificationsPermission() ?? false;
      await android.requestExactAlarmsPermission();
      return granted;
    }
    if (ios != null) {
      final granted = await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return granted;
    }
    return false;
  }

  Future<bool> checkPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    // iOS не даёт проверить статус без запроса, считаем включёнными
    return true;
  }

  Future<void> scheduleEventReminders({
    required int eventId,
    required String eventTitle,
    required DateTime eventDateTime,
    required Set<ReminderOffset> reminders,
    String? memberName,
  }) async {
    await cancelEventReminders(eventId);

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

  Future<void> cancelEventReminders(int eventId) async {
    for (final reminder in ReminderOffset.values) {
      await _plugin.cancel(_notificationId(eventId, reminder));
    }
  }

  Future<void> saveEventReminders(
    int eventId,
    Set<ReminderOffset> reminders,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final indices = reminders.map((r) => r.index).toList();
    await prefs.setString(
      '$_prefsKeyPrefix$eventId',
      jsonEncode(indices),
    );
  }

  Future<Set<ReminderOffset>> loadEventReminders(int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefsKeyPrefix$eventId');
    if (raw == null) return {};
    final List<dynamic> indices = jsonDecode(raw);
    return indices
        .map((i) => ReminderOffset.values[i as int])
        .toSet();
  }

  Future<void> clearEventReminders(int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefsKeyPrefix$eventId');
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
}
