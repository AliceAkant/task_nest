part of 'settings_cubit.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool notificationsEnabled;
  final DailyBriefSettings dailyBrief;

  const SettingsLoaded({
    required this.notificationsEnabled,
    required this.dailyBrief,
  });

  SettingsLoaded copyWith({
    bool? notificationsEnabled,
    DailyBriefSettings? dailyBrief,
  }) {
    return SettingsLoaded(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyBrief: dailyBrief ?? this.dailyBrief,
    );
  }

  @override
  List<Object?> get props => [notificationsEnabled, dailyBrief];
}
