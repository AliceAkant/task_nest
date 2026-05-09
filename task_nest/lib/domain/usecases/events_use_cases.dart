import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/repositories/events_repository.dart';

class GetAllEventsUseCase {
  final EventsRepository repository;

  GetAllEventsUseCase(this.repository);

  Future<Either<Failure, List<Event>>> call() => repository.getAllEvents();
}

class GetEventsBetweenDateUseCase {
  final EventsRepository repository;

  GetEventsBetweenDateUseCase(this.repository);

  Future<Either<Failure, List<Event>>> call(DateTime start, DateTime end) =>
      repository.getEventsBetween(start, end);
}

class GetEventsCountUseCase {
  final EventsRepository repository;

  GetEventsCountUseCase(this.repository);

  Future<Either<Failure, Map<DateTime, int>>> call(
    DateTime start,
    int monthsCount,
  ) => repository.getEventsCount(start, monthsCount);
}

class AddEventUseCase {
  final EventsRepository repository;

  AddEventUseCase(this.repository);

  Future<Either<Failure, Event>> call(Event event) =>
      repository.addEvent(event);
}

class UpdateEventUseCase {
  final EventsRepository repository;

  UpdateEventUseCase(this.repository);

  Future<Either<Failure, Event>> call(Event event) =>
      repository.updateEvent(event);
}

class DeleteEventUseCase {
  final EventsRepository repository;

  DeleteEventUseCase(this.repository);

  Future<Either<Failure, bool>> call(int eventId) =>
      repository.deleteEvent(eventId);
}
