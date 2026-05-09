import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/domain/entities/daily_brief_settings.dart';
import 'package:task_nest/domain/usecases/app_preferences_use_cases.dart';
import 'package:task_nest/domain/usecases/notifications_use_cases.dart';
import 'package:task_nest/infrastructure/di/injection.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetNotificationsStateUseCase _getState;
  final SetNotificationsMutedUseCase _setMuted;
  final OpenNotificationSettingsUseCase _openSettings;
  final GetDailyBriefSettingsUseCase _getDailyBrief;
  final SetDailyBriefSettingsUseCase _setDailyBrief;
  final RescheduleDailyBriefUseCase _rescheduleDailyBrief;

  bool? _lastOsGranted;

  SettingsCubit()
    : _getState = DI.container<GetNotificationsStateUseCase>(),
      _setMuted = DI.container<SetNotificationsMutedUseCase>(),
      _openSettings = DI.container<OpenNotificationSettingsUseCase>(),
      _getDailyBrief = DI.container<GetDailyBriefSettingsUseCase>(),
      _setDailyBrief = DI.container<SetDailyBriefSettingsUseCase>(),
      _rescheduleDailyBrief = DI.container<RescheduleDailyBriefUseCase>(),
      super(SettingsInitial()) {
    refreshState();
  }

  Future<void> tabOpened() => refreshState();

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
    await _rescheduleDailyBrief.call();
    await refreshState();
  }

  Future<void> toggleDailyBrief(bool enabled) async {
    final current = await _getDailyBrief.call();
    final s = await _getState.call();
    if (enabled && !s.osGranted) {
      await _openSettings.call();
      return;
    }
    final updated = current.copyWith(enabled: enabled);
    await _setDailyBrief.call(updated);
    await _rescheduleDailyBrief.call();
    _emitLoaded(notificationsEnabled: s.isActive, dailyBrief: updated);
  }

  Future<void> setDailyBriefTime(int hour, int minute) async {
    final current = await _getDailyBrief.call();
    final updated = current.copyWith(hour: hour, minute: minute);
    await _setDailyBrief.call(updated);
    if (updated.enabled) {
      await _rescheduleDailyBrief.call();
    }
    final s = await _getState.call();
    _emitLoaded(notificationsEnabled: s.isActive, dailyBrief: updated);
  }

  /// Reads OS+app state. If the OS permission flipped from denied to granted
  /// since the last check (typical: user came back from System Settings after
  /// tapping the switcher), align the in-app mute too — the act of granting
  /// is an explicit "I want notifications" signal.
  Future<void> refreshState() async {
    final s = await _getState.call();
    final justGotGranted = _lastOsGranted == false && s.osGranted;
    _lastOsGranted = s.osGranted;

    if (justGotGranted && s.muted) {
      await _setMuted.call(false);
      await _rescheduleDailyBrief.call();
      final brief = await _getDailyBrief.call();
      _emitLoaded(notificationsEnabled: true, dailyBrief: brief);
      return;
    }
    final brief = await _getDailyBrief.call();
    _emitLoaded(notificationsEnabled: s.isActive, dailyBrief: brief);
  }

  void _emitLoaded({
    required bool notificationsEnabled,
    required DailyBriefSettings dailyBrief,
  }) {
    emit(SettingsLoaded(
      notificationsEnabled: notificationsEnabled,
      dailyBrief: dailyBrief,
    ));
  }
}
