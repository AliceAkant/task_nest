import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/entities/event.dart';

abstract class EventsRepository {
  Future<Either<Failure, List<Event>>> getAllEvents();
  Future<Either<Failure, List<Event>>> getEventsByDate(DateTime date);
  Future<Either<Failure, List<Event>>> getEventsBetween(
    DateTime start,
    DateTime end,
  );
  Future<Either<Failure, List<Event>>> getEventsByMemberId(int? memberId);
  Future<Either<Failure, Event>> addEvent(Event event);
  Future<Either<Failure, Event>> updateEvent(Event event);
  Future<Either<Failure, bool>> deleteEvent(int eventId);
}
