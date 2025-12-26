import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/repositories/events_repository.dart';

class UpdateEventUseCase {
  final EventsRepository repository;

  UpdateEventUseCase(this.repository);

  Future<Either<Failure, Event>> call(Event event) =>
      repository.updateEvent(event);
}
