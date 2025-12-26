import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/repositories/events_repository.dart';

class AddEventUseCase {
  final EventsRepository repository;

  AddEventUseCase(this.repository);

  Future<Either<Failure, Event>> call(
    String title,
    DateTime dateTime,
    Member? member,
    String? notes,
  ) {
    final event = Event(
      id: null,
      title: title,
      dateTime: dateTime,
      member: member,
      notes: notes,
    );
    return repository.addEvent(event);
  }
}
