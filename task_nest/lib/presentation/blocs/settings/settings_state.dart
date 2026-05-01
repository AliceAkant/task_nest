part of 'settings_cubit.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool notificationsEnabled;

  const SettingsLoaded({required this.notificationsEnabled});

  @override
  List<Object?> get props => [notificationsEnabled];
}
