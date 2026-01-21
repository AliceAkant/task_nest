import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/repositories/events_repository.dart';

class GetEventsCountUseCase {
  final EventsRepository repository;

  GetEventsCountUseCase(this.repository);

  Future<Either<Failure, Map<DateTime, int>>> call(DateTime date, int months) =>
      repository.getEventsCount(date, months);
}
