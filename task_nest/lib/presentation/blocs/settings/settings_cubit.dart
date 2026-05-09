import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/domain/usecases/notifications_use_cases.dart';
import 'package:task_nest/infrastructure/di/injection.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetNotificationsStateUseCase _getState;
  final SetNotificationsMutedUseCase _setMuted;
  final OpenNotificationSettingsUseCase _openSettings;

  bool? _lastOsGranted;

  SettingsCubit()
    : _getState = DI.container<GetNotificationsStateUseCase>(),
      _setMuted = DI.container<SetNotificationsMutedUseCase>(),
      _openSettings = DI.container<OpenNotificationSettingsUseCase>(),
      super(SettingsInitial()) {
    refreshPermissionState();
  }

  Future<void> tabOpened() => refreshPermissionState();

  /// Tap on the switcher.
  /// * OS denied  → open OS settings (state will resync on resume).
  /// * Otherwise  → flip in-app mute.
  Future<void> toggleNotifications(bool enable) async {
    final s = await _getState.call();
    if (!s.osGranted) {
      await _openSettings.call();
      return;
    }
    await _setMuted.call(!enable);
    await refreshPermissionState();
  }

  /// Reads OS+app state. If the OS permission flipped from denied to granted
  /// since the last check (typical: user came back from System Settings after
  /// tapping the switcher), align the in-app mute too — the act of granting
  /// is an explicit "I want notifications" signal.
  Future<void> refreshPermissionState() async {
    final s = await _getState.call();
    final justGotGranted = _lastOsGranted == false && s.osGranted;
    _lastOsGranted = s.osGranted;

    if (justGotGranted && s.muted) {
      await _setMuted.call(false);
      emit(const SettingsLoaded(notificationsEnabled: true));
      return;
    }
    emit(SettingsLoaded(notificationsEnabled: s.isActive));
  }
}
