import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/infrastructure/di/injection.dart';
import 'package:task_nest/infrastructure/notifications/notification_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final NotificationService _notifications;

  SettingsCubit()
    : _notifications = DI.container<NotificationService>(),
      super(SettingsInitial());

  Future<void> tabOpened() async {
    final enabled = await _notifications.checkPermissions();
    emit(SettingsLoaded(notificationsEnabled: enabled));
  }

  Future<void> toggleNotifications(bool enable) async {
    if (enable) {
      await _notifications.requestPermissions();
    }
    // Перечитываем реальное состояние из OS (нельзя выключить программно)
    final current = await _notifications.checkPermissions();
    emit(SettingsLoaded(notificationsEnabled: current));
  }
}
