import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/repositories/events_repository.dart';

class DeleteEventUseCase {
  final EventsRepository repository;

  DeleteEventUseCase(this.repository);

  Future<Either<Failure, bool>> call(int eventId) =>
      repository.deleteEvent(eventId);
}
