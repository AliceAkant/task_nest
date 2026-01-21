import 'package:get_it/get_it.dart';
import 'package:task_nest/core/logger/logger_service.dart';
import 'package:task_nest/data/datasources/local/events_local_datasource.dart';
import 'package:task_nest/data/datasources/local/members_local_datasource.dart';
import 'package:task_nest/data/datasources/shared_preferences_datasource.dart';
import 'package:task_nest/data/repositories_impl/events_repository_impl.dart';
import 'package:task_nest/data/repositories_impl/members_repository_impl.dart';
import 'package:task_nest/data/repositories_impl/user_profile_repository_impl.dart';
import 'package:task_nest/domain/repositories/events_repository.dart';
import 'package:task_nest/domain/repositories/members_repository.dart';
import 'package:task_nest/domain/repositories/user_profile_repository.dart';
import 'package:task_nest/domain/usecases/events/add_event_usecase.dart';
import 'package:task_nest/domain/usecases/events/delete_event_usecase.dart';
import 'package:task_nest/domain/usecases/events/get_events_count_usecase.dart';
import 'package:task_nest/domain/usecases/events/update_event_usecase.dart';
import 'package:task_nest/domain/usecases/events/get_events_between_date_usecase.dart';
import 'package:task_nest/domain/usecases/events/get_events_by_date_usecase.dart';
import 'package:task_nest/domain/usecases/members/add_member_usecase.dart';
import 'package:task_nest/domain/usecases/members/delete_member_usecase.dart';
import 'package:task_nest/domain/usecases/members/update_member_usecase.dart';
import 'package:task_nest/domain/usecases/members/get_members_usecase.dart';
import 'package:task_nest/domain/usecases/events/get_all_events_usecase.dart';
import 'package:task_nest/domain/usecases/user/get_user_usecase.dart';
import 'package:task_nest/domain/usecases/user/initialize_user_usecase.dart';
import 'package:task_nest/domain/usecases/user/update_user_usecase.dart';
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
      () => GetEventsByDateUseCase(container<EventsRepository>()),
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
  }
}
