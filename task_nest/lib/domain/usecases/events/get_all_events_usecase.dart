import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/repositories/events_repository.dart';

class GetAllEventsUseCase {
  final EventsRepository repository;

  GetAllEventsUseCase(this.repository);

  Future<Either<Failure, List<Event>>> call() => repository.getAllEvents();
}
