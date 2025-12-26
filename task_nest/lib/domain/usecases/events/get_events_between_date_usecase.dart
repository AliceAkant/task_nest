import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/repositories/events_repository.dart';

class GetEventsBetweenDateUseCase {
  final EventsRepository repository;

  GetEventsBetweenDateUseCase(this.repository);

  Future<Either<Failure, List<Event>>> call(DateTime start, DateTime end) =>
      repository.getEventsBetween(start, end);
}
