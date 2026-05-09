import 'package:get_it/get_it.dart';
import 'package:task_nest/core/logger/logger_service.dart';
import 'package:task_nest/data/datasources/local/events_local_datasource.dart';
import 'package:task_nest/data/datasources/local/members_local_datasource.dart';
import 'package:task_nest/data/datasources/shared_preferences_datasource.dart';
import 'package:task_nest/data/repositories_impl/app_preferences_repository_impl.dart';
import 'package:task_nest/data/repositories_impl/events_repository_impl.dart';
import 'package:task_nest/data/repositories_impl/members_repository_impl.dart';
import 'package:task_nest/data/repositories_impl/notifications_repository_impl.dart';
import 'package:task_nest/data/repositories_impl/user_profile_repository_impl.dart';
import 'package:task_nest/domain/repositories/app_preferences_repository.dart';
import 'package:task_nest/domain/repositories/events_repository.dart';
import 'package:task_nest/domain/repositories/members_repository.dart';
import 'package:task_nest/domain/repositories/notifications_repository.dart';
import 'package:task_nest/domain/repositories/user_profile_repository.dart';
import 'package:task_nest/domain/usecases/app_preferences_use_cases.dart';
import 'package:task_nest/domain/usecases/events_use_cases.dart';
import 'package:task_nest/domain/usecases/members_use_cases.dart';
import 'package:task_nest/domain/usecases/notifications_use_cases.dart';
import 'package:task_nest/domain/usecases/user_use_cases.dart';
import 'package:task_nest/infrastructure/storage/drift/app_database.dart';

class DI {
  static final GetIt container = GetIt.instance;

  Future initializeDependencies() async {
    final db = AppDatabase();
    container.registerSingleton<AppDatabase>(db);

    container.registerSingleton<LoggerService>(LoggerService());

    ///
    /// DataSource
    ///

    container.registerLazySingleton(
      () => EventsLocalDataSource(container<AppDatabase>()),
    );
    container.registerLazySingleton(
      () => MembersLocalDataSource(container<AppDatabase>()),
    );
    container.registerLazySingleton(() => SharedPreferencesDataSource());

    ///
    /// Abstract (repositories)
    ///

    container.registerLazySingleton<EventsRepository>(
      () => EventsRepositoryImpl(container<EventsLocalDataSource>()),
    );
    container.registerLazySingleton<MembersRepository>(
      () => MembersRepositoryImpl(container<MembersLocalDataSource>()),
    );
    container.registerLazySingleton<UserProfileRepository>(
      () => UserProfileRepositoryImpl(container<SharedPreferencesDataSource>()),
    );
    final notificationsImpl = NotificationsRepositoryImpl();
    await notificationsImpl.initialize();
    container.registerSingleton<NotificationsRepository>(notificationsImpl);
    container.registerLazySingleton<AppPreferencesRepository>(
      () => AppPreferencesRepositoryImpl(),
    );

    ///
    /// UseCases
    ///

    // User
    container.registerFactory(
      () => InitializeUserUseCase(container<UserProfileRepository>()),
    );
    container.registerFactory(
      () => GetUserUseCase(container<UserProfileRepository>()),
    );
    container.registerFactory(
      () => UpdateUserUseCase(container<UserProfileRepository>()),
    );

    // Events
    container.registerFactory(
      () => GetAllEventsUseCase(container<EventsRepository>()),
    );
    container.registerFactory(
      () => GetEventsBetweenDateUseCase(container<EventsRepository>()),
    );
    container.registerFactory(
      () => GetEventsCountUseCase(container<EventsRepository>()),
    );
    container.registerFactory(
      () => AddEventUseCase(container<EventsRepository>()),
    );
    container.registerFactory(
      () => UpdateEventUseCase(container<EventsRepository>()),
    );
    container.registerFactory(
      () => DeleteEventUseCase(container<EventsRepository>()),
    );

    // Members
    container.registerFactory(
      () => GetMembersUseCase(container<MembersRepository>()),
    );
    container.registerFactory(
      () => AddMemberUseCase(container<MembersRepository>()),
    );
    container.registerFactory(
      () => UpdateMemberUseCase(container<MembersRepository>()),
    );
    container.registerFactory(
      () => DeleteMemberUseCase(container<MembersRepository>()),
    );

    // Notifications
    container.registerFactory(
      () => GetNotificationsStateUseCase(
        container<NotificationsRepository>(),
        container<AppPreferencesRepository>(),
      ),
    );
    container.registerFactory(
      () => RequestNotificationPermissionUseCase(
        container<NotificationsRepository>(),
      ),
    );
    container.registerFactory(
      () =>
          OpenNotificationSettingsUseCase(container<NotificationsRepository>()),
    );
    container.registerFactory(
      () => SetNotificationsMutedUseCase(
        container<AppPreferencesRepository>(),
        container<NotificationsRepository>(),
        container<EventsRepository>(),
      ),
    );
    container.registerFactory(
      () => ScheduleEventRemindersUseCase(
        container<NotificationsRepository>(),
        container<AppPreferencesRepository>(),
      ),
    );
    container.registerFactory(
      () => RemoveEventRemindersUseCase(container<NotificationsRepository>()),
    );
    container.registerFactory(
      () => LoadEventRemindersUseCase(container<NotificationsRepository>()),
    );

    // Preferences
    container.registerFactory(
      () => GetThemeModeUseCase(container<AppPreferencesRepository>()),
    );
    container.registerFactory(
      () => SetThemeModeUseCase(container<AppPreferencesRepository>()),
    );
    container.registerFactory(
      () => GetLocaleKeyUseCase(container<AppPreferencesRepository>()),
    );
    container.registerFactory(
      () => SetLocaleKeyUseCase(container<AppPreferencesRepository>()),
    );
  }
}
