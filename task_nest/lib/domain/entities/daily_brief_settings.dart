import 'package:equatable/equatable.dart';

class DailyBriefSettings extends Equatable {
  static const int defaultHour = 8;
  static const int defaultMinute = 0;

  final bool enabled;
  final int hour;
  final int minute;

  const DailyBriefSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  const DailyBriefSettings.defaults()
    : enabled = false,
      hour = defaultHour,
      minute = defaultMinute;

  DailyBriefSettings copyWith({bool? enabled, int? hour, int? minute}) {
    return DailyBriefSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  @override
  List<Object?> get props => [enabled, hour, minute];
}
