import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/core/logger/logger_helper.dart';
import 'package:task_nest/data/datasources/local/events_local_datasource.dart';
import 'package:task_nest/data/dto_models/local/event_drift_dto.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/repositories/events_repository.dart';

class EventsRepositoryImpl implements EventsRepository {
  final EventsLocalDataSource local;

  EventsRepositoryImpl(this.local);

  @override
  Future<Either<Failure, List<Event>>> getAllEvents() async {
    LoggerHelper.info('Try to load events');

    final result = await local.getAllEvents();

    return result.fold(
      (failure) {
        LoggerHelper.databaseError('Load events failed: ${failure.message}');

        return Left(failure);
      },
      (list) {
        LoggerHelper.info('Load events success: ${list.length} items');

        return Right(list.map((e) => e.toEntity()).toList());
      },
    );
  }

  @override
  Future<Either<Failure, List<Event>>> getEventsBetween(
    DateTime start,
    DateTime end,
  ) async {
    LoggerHelper.info(
      'Try to load events between ${start.toIso8601String()} and ${end.toIso8601String()}',
    );

    final result = await local.getEventsBetween(start, end);

    return result.fold(
      (failure) {
        LoggerHelper.databaseError(
          'Load events between failed: ${failure.message}',
        );

        return Left(failure);
      },
      (list) {
        LoggerHelper.info('Load events between success: ${list.length} items');
        return Right(list.map((e) => e.toEntity()).toList());
      },
    );
  }

  @override
  Future<Either<Failure, List<Event>>> getEventsByDate(DateTime date) async {
    LoggerHelper.info('try to load events by date: ${date.toIso8601String()}');

    final result = await local.getEventsByDate(date);

    return result.fold(
      (failure) {
        LoggerHelper.databaseError(
          'Load events by date failed: ${failure.message}',
        );
        return Left(failure);
      },
      (list) {
        LoggerHelper.info('Load events by date success: ${list.length} items');
        return Right(list.map((e) => e.toEntity()).toList());
      },
    );
  }

  @override
  Future<Either<Failure, List<Event>>> getEventsByMemberId(
    int? memberId,
  ) async {
    LoggerHelper.info('Try to load events by member: ${memberId ?? 'null'}');

    final result = await local.getEventsByMemberId(memberId);

    return result.fold(
      (failure) {
        LoggerHelper.databaseError(
          'Load events by member failed: ${failure.message}',
        );
        return Left(failure);
      },
      (list) {
        LoggerHelper.info(
          'Load events by member success: ${list.length} items',
        );
        return Right(list.map((e) => e.toEntity()).toList());
      },
    );
  }

  @override
  Future<Either<Failure, Map<DateTime, int>>> getEventsCount(
    DateTime start,
    int monthsCount,
  ) async {
    LoggerHelper.info(
      'Try to load events count between: $start + $monthsCount months',
    );

    final result = await local.getEventsCount(start, monthsCount);

    return result.fold(
      (failure) {
        LoggerHelper.databaseError(
          'Load events count failed: ${failure.message}',
        );
        return Left(failure);
      },
      (map) {
        LoggerHelper.info('Load events count success');
        return Right(map);
      },
    );
  }

  @override
  Future<Either<Failure, Event>> addEvent(Event event) async {
    LoggerHelper.info('Try add event: ${event.toString()}');

    final dto = EventDriftDto.fromEntity(event);

    final result = await local.addEvent(dto);

    return result.fold(
      (failure) {
        LoggerHelper.databaseError('Add event failed: ${failure.message}');
        return Left(failure);
      },
      (savedDTO) {
        LoggerHelper.info('Add event success: [id: ${savedDTO.id}]');
        return Right(savedDTO.toEntity());
      },
    );
  }

  @override
  Future<Either<Failure, Event>> updateEvent(Event event) async {
    LoggerHelper.info(
      'Try update event: ${event.id} with fields ${event.toString()}',
    );

    final dto = EventDriftDto.fromEntity(event);

    final result = await local.editEvent(dto);

    return result.fold(
      (failure) {
        LoggerHelper.databaseError(
          'Update event ${event.id} failed: ${failure.message}',
        );
        return Left(failure);
      },
      (updatedDTO) {
        LoggerHelper.info('Update event ${event.id} success');
        return Right(updatedDTO.toEntity());
      },
    );
  }

  @override
  Future<Either<Failure, bool>> deleteEvent(int eventId) async {
    LoggerHelper.info('Try delete event: $eventId');

    final result = await local.deleteEvent(eventId);

    return result.fold(
      (failure) {
        LoggerHelper.databaseError('Delete event failed: ${failure.message}');
        return Left(failure);
      },
      (success) {
        LoggerHelper.info('Delete event $eventId success');
        return Right(success);
      },
    );
  }
}
