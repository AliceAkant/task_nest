enum ReminderOffset {
  tenMinutes,
  thirtyMinutes,
  oneHour,
  twelveHours,
  oneDay,
  threeDays;

  Duration get duration => switch (this) {
    ReminderOffset.tenMinutes => const Duration(minutes: 10),
    ReminderOffset.thirtyMinutes => const Duration(minutes: 30),
    ReminderOffset.oneHour => const Duration(hours: 1),
    ReminderOffset.twelveHours => const Duration(hours: 12),
    ReminderOffset.oneDay => const Duration(days: 1),
    ReminderOffset.threeDays => const Duration(days: 3),
  };

  String labelEn() => switch (this) {
    ReminderOffset.tenMinutes => '10 minutes before',
    ReminderOffset.thirtyMinutes => '30 minutes before',
    ReminderOffset.oneHour => '1 hour before',
    ReminderOffset.twelveHours => '12 hours before',
    ReminderOffset.oneDay => '1 day before',
    ReminderOffset.threeDays => '3 days before',
  };

  String labelRu() => switch (this) {
    ReminderOffset.tenMinutes => 'За 10 минут',
    ReminderOffset.thirtyMinutes => 'За 30 минут',
    ReminderOffset.oneHour => 'За 1 час',
    ReminderOffset.twelveHours => 'За 12 часов',
    ReminderOffset.oneDay => 'За 1 день',
    ReminderOffset.threeDays => 'За 3 дня',
  };
}
