import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/repositories/events_repository.dart';

class GetEventsByDateUseCase {
  final EventsRepository repository;

  GetEventsByDateUseCase(this.repository);

  Future<Either<Failure, List<Event>>> call(DateTime date) =>
      repository.getEventsByDate(date);
}
