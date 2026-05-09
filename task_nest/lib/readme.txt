TASK_NEST - Architecture Guide
==============================

Clean Architecture + BLoC/Cubit. Strict layering with one-way dependencies:

    presentation → domain ← data
                    ↑
             infrastructure (concrete tech)
                    ↑
                 core (utils, no Flutter deps)

Data flow:
    UI → Cubit → UseCase → Repository (abstract) → Repository Impl → DB / Prefs / OS API


Project structure
-----------------
lib/
 ├── core/                       // pure utilities, NO Flutter/infra deps
 │    ├── error/                 // Failure types for Either<Failure, T>
 │    ├── extensions/            // DateTime, etc. - usable in any layer
 │    ├── logger/                // LoggerService + LoggerHelper
 │    └── shared_prefs/          // SharedPreferences factory + keys
 │
 ├── domain/                     // pure Dart, NO Flutter, NO infra imports
 │    ├── entities/              // Event, Member, UserProfile, UserSettings,
 │    │                          //   NotificationsState
 │    ├── enums/                 // Avatar, MemberTheme, ReminderOffset,
 │    │                          //   AppThemeMode, NotificationPermissionResult
 │    ├── helpers/               // enum converters
 │    ├── repositories/          // ABSTRACT contracts:
 │    │                          //   EventsRepository, MembersRepository,
 │    │                          //   UserProfileRepository, NotificationsRepository,
 │    │                          //   AppPreferencesRepository
 │    └── usecases/              // grouped by feature, one file per area:
 │         ├── events_use_cases.dart        // GetAll / GetEventsBetween / Count /
 │         │                                //   Add / Update / Delete
 │         ├── members_use_cases.dart       // Get / Add / Update / Delete
 │         ├── user_use_cases.dart          // Initialize / Get / Update
 │         ├── app_preferences_use_cases.dart
 │         │                                // Get/Set theme mode + locale key
 │         └── notifications_use_cases.dart // GetState (osGranted+muted),
 │                                          //   RequestPermission (silent),
 │                                          //   OpenSystemSettings,
 │                                          //   SetMuted (orchestrates cancel/
 │                                          //   reschedule),
 │                                          //   ScheduleEventReminders,
 │                                          //   RemoveEventReminders,
 │                                          //   LoadEventReminders
 │
 ├── data/                       // implementations of domain contracts
 │    ├── datasources/           // Drift queries, SharedPreferences I/O
 │    │    ├── local/            //   events, members (Drift)
 │    │    ├── backend/          //   reserved for future remote sources
 │    │    └── shared_preferences_datasource.dart
 │    ├── dto_models/            // DB DTOs ↔ entity mappers (toEntity / fromEntity)
 │    │    └── local/
 │    ├── helpers/               // color converter, etc.
 │    └── repositories_impl/     // Repo impls. NotificationsRepositoryImpl
 │                               //   talks to platform plugins directly
 │                               //   (flutter_local_notifications,
 │                               //   permission_handler, app_settings, timezone).
 │
 ├── infrastructure/             // 3rd-party tech that needs no abstraction
 │    ├── di/                    // GetIt registration (DI.container)
 │    ├── routes/                // go_router config
 │    ├── localization/          // easy_localization config + keys + models
 │    └── storage/               // Drift database
 │         └── drift/
 │
 └── presentation/               // UI layer
      ├── application.dart       // root MaterialApp
      ├── blocs/                 // Cubits/Blocs - depend ONLY on usecases
      │    ├── base_form/        //   shared form cubit base
      │    ├── bottom_navigation/ //  nav tab state
      │    ├── event_form/       //   add/edit event
      │    ├── events_count/     //   monthly count for calendar dots
      │    ├── greeting/         //   onboarding
      │    ├── localization/
      │    ├── member_form/
      │    ├── members/
      │    ├── profile/
      │    ├── schedule/         //   day/week/month views, filters
      │    ├── settings/
      │    ├── splash/           //   app start-up sequence
      │    └── user/
      ├── enum/                  // UI enums (AppSvg, FormMode, view modes, ...)
      ├── extensions/            // BuildContext, String, AvatarAsset
      ├── helpers/               // app_bar, popups, bottom sheets, assets
      ├── models/
      ├── screens/               // routed pages
      ├── theme/                 // colors, sizes, typography, ThemeCubit
      └── widgets/               // reusable: cards, inputs, views, states


Layer rules
-----------
* domain/ MUST NOT import anything from data/, infrastructure/, presentation/, Flutter.
* data/ MAY depend on domain/, core/, infrastructure/storage/. May import platform
  plugins directly (those represent IO and belong here, not in infrastructure/).
* infrastructure/ MAY depend on domain/, core/. NOT on presentation/, data/.
* presentation/ depends on domain/ usecases. NEVER directly on data/ or DB.
  (DI access for usecase resolution is fine.)
* core/ has no in-project deps - pure utilities.


Use case style
--------------
* One class per business action, grouped by feature in a single file
  (events_use_cases.dart, members_use_cases.dart, …). Multi-class-per-file
  is intentional — no need for one tiny file per UC.
* CRUD UCs take an entity and forward to the repo. Logic-bearing UCs
  (`GetNotificationsStateUseCase`, `SetNotificationsMutedUseCase`,
  `ScheduleEventRemindersUseCase`) compose multiple repos and live alongside.
* All UCs return Either<Failure, T> when they touch the DB; pure-state UCs
  return their domain value directly.


Adding a new feature - checklist
--------------------------------
1. domain/entities/        - add entity if needed (no Flutter).
2. domain/repositories/    - add methods on the repo interface (abstract).
3. data/datasources/       - implement raw IO (Drift / Prefs / network / OS).
4. data/repositories_impl/ - implement; map DTO→entity; log; return Either.
5. domain/usecases/<feature>_use_cases.dart - add UC class(es). Trivial CRUD =
   1-line forward to repo. Logic-bearing UCs go in the same file.
6. infrastructure/di/      - register datasource → repo (abstract→impl) → UC.
7. presentation/blocs/     - Cubit takes UCs via DI.container in its ctor.
8. presentation/screens/   - wire up with BlocProvider / BlocBuilder.


DI conventions (lib/infrastructure/di/injection.dart)
-----------------------------------------------------
* Long-lived singletons:  AppDatabase, LoggerService.
                          NotificationsRepositoryImpl is registered as a
                          singleton with awaited initialize() before use.
* registerLazySingleton:  datasources + repository abstractions.
* registerFactory:        usecases (cheap, stateless).
* Cubits are NOT registered in DI - they're created via BlocProvider and
  pull UCs from DI.container in their constructors.


Error handling
--------------
* DataSourceHelper.executeSafe catches throwables → returns Left(Failure).
* Repos forward Either<Failure, T> upward, logging at the boundary.
* UseCases return Either<Failure, T> unchanged.
* BaseFormCubit.processUseCaseResult unwraps Either; on Left it emits an error
  state with failure.message.


Notifications (flow recap)
--------------------------
* Permission state has TWO layers:
  - OS layer  — granted / denied / permanentlyDenied.
  - App layer — `notificationsMuted` flag in SharedPreferences (in-app mute).
  GetNotificationsStateUseCase returns NotificationsState(osGranted, muted)
  with computed flags `isActive`, `isMutedLocally`, `isDisabledByOS`.

* On app start (SplashCubit): RequestNotificationPermissionUseCase fires the
  OS dialog if the status is undetermined. It NEVER opens OS Settings —
  redirecting on splash is jarring. Callers handle "denied" themselves.

* Settings switcher reflects state.isActive.
  - Tap when OS denied  → OpenNotificationSettingsUseCase (lifecycle observer
                          re-syncs on resume).
  - Tap when OS granted → SetNotificationsMutedUseCase(!enable).
                          Mute  = persist + cancelAll pending OS notifications.
                          Unmute= persist + reschedule every future event's
                                  saved offsets via zonedSchedule. Reminders
                                  resume exactly on time.

* Event reminders: ScheduleEventRemindersUseCase always persists offsets;
  it skips OS scheduling when muted (offsets are still saved, so the next
  unmute resurrects them). RemoveEventRemindersUseCase undoes both.

* In EventForm dropdown:
  - OS denied → items locked (lock icon); tap → OpenNotificationSettings.
  - Locally muted (OS granted) → items NOT locked; picking any offset other
    than "Don't remind" auto-unmutes globally before adding to state.
  - "Don't remind" is always available.


Persistence
-----------
* Drift  (infrastructure/storage/drift) - events, members.
* SharedPreferences (core/shared_prefs) - user profile, theme, locale,
  notifications-muted flag, per-event reminder offsets.


Localization
------------
* easy_localization, JSONs in assets/translations/.
* Keys generated/maintained in infrastructure/localization/locale_keys.dart.
* LocalizationCubit persists chosen locale via SetLocaleKeyUseCase.
