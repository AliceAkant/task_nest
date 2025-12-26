import 'package:easy_localization/easy_localization.dart';

extension DateExtension on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  String get dateSimpleFormat => DateFormat('dd.MM.yy').format(this);

  String dMMMM(String localeKey) =>
      DateFormat('d MMMM', localeKey).format(this);

  String toTimeFormat(String localeKey) {
    return localeKey == 'en_US'
        ? DateFormat('hh:mm a', 'en_US').format(this)
        : DateFormat('HH:mm', 'ru_RU').format(this);
  }

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}
