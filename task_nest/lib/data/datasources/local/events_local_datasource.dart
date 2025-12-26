import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/data/datasources/datasource_helper.dart';
import 'package:task_nest/data/dto_models/local/event_drift_dto.dart';
import 'package:task_nest/data/dto_models/local/member_drift_dto.dart';
import 'package:task_nest/infrastructure/storage/drift/app_database.dart';
import 'package:task_nest/presentation/extensions/date_time_extension.dart';

class EventsLocalDataSource {
  final AppDatabase db;

  // General "join" by member
  Join get _memberJoin =>
      leftOuterJoin(db.members, db.members.id.equalsExp(db.events.memberId));

  EventsLocalDataSource(this.db);

  Future<Either<Failure, List<EventDriftDto>>> getAllEvents() async {
    return DataSourceHelper.executeSafe(
      action: () async {
        final query = db.select(db.events).join([_memberJoin]);

        final rows = await query.get();

        final result = rows.map((row) {
          final event = row.readTable(db.events);
          final member = row.readTableOrNull(db.members);

          return _formatEventDTO(event, member);
        }).toList();

        return result;
      },
      errorTitle: "Failed to get all events",
    );
  }

  Future<Either<Failure, List<EventDriftDto>>> getEventsByDate(
    DateTime date,
  ) async {
    final startOfDay = date.dateOnly;
    final endOfDay = date.endOfDay;

    return DataSourceHelper.executeSafe(
      action: () async {
        final query = db.select(db.events).join([_memberJoin]);
        query.where(
          db.events.timeDate.isBiggerOrEqualValue(startOfDay) &
              db.events.timeDate.isSmallerOrEqualValue(endOfDay),
        );

        final rows = await query.get();

        final result = rows.map((row) {
          final event = row.readTable(db.events);
          final member = row.readTableOrNull(db.members);

          return _formatEventDTO(event, member);
        }).toList();

        return result;
      },
      errorTitle: "Failed to get events by date ${startOfDay.toString()}",
    );
  }

  Future<Either<Failure, List<EventDriftDto>>> getEventsBetween(
    DateTime start,
    DateTime end,
  ) async {
    final startDay = start.dateOnly;
    final endDay = end.endOfDay;

    return DataSourceHelper.executeSafe(
      action: () async {
        final query = db.select(db.events).join([_memberJoin]);
        query.where(db.events.timeDate.isBetweenValues(startDay, endDay));

        final rows = await query.get();

        final result = rows.map((row) {
          final event = row.readTable(db.events);
          final member = row.readTableOrNull(db.members);

          return _formatEventDTO(event, member);
        }).toList();

        return result;
      },
      errorTitle:
          "Failed to get events between ${startDay.toString()} - ${endDay.toString()}",
    );
  }

  Future<Either<Failure, List<EventDriftDto>>> getEventsByMemberId(
    int? memberId,
  ) async {
    return DataSourceHelper.executeSafe(
      action: () async {
        final query = db.select(db.events).join([_memberJoin]);

        if (memberId == null) {
          query.where(db.events.memberId.isNull());
        } else {
          query.where(db.events.memberId.equals(memberId));
        }

        final rows = await query.get();

        final result = rows.map((row) {
          final event = row.readTable(db.events);
          final member = row.readTableOrNull(db.members);

          return _formatEventDTO(event, member);
        }).toList();

        return result;
      },
      errorTitle: "Failed to get events by member $memberId",
    );
  }

  Future<Either<Failure, EventDriftDto>> addEvent(EventDriftDto event) async {
    return DataSourceHelper.executeSafe(
      action: () async {
        final model = EventsCompanion.insert(
          title: event.title,
          timeDate: event.timeDate,
          notes: Value(event.notes),
          memberId: Value(event.member?.id),
        );

        final id = await db.into(db.events).insert(model);

        return event.copyWith(id: id);
      },
      errorTitle: 'Failed to add event',
    );
  }

  Future<Either<Failure, EventDriftDto>> editEvent(EventDriftDto event) async {
    return DataSourceHelper.executeSafe(
      action: () async {
        final model = EventsCompanion(
          title: Value(event.title),
          timeDate: Value(event.timeDate),
          notes: Value(event.notes),
          memberId: Value(event.member?.id),
        );

        final query = db.update(db.events)
          ..where((tbl) => tbl.id.equals(event.id));

        await query.write(model);

        return event;
      },
      errorTitle: 'Failed to update event ${event.id}',
    );
  }

  Future<Either<Failure, bool>> deleteEvent(int eventId) async {
    return DataSourceHelper.executeSafe(
      action: () async {
        final query = db.delete(db.events)..where((e) => e.id.equals(eventId));

        final count = await query.go();

        return count > 0;
      },
      errorTitle: 'Failed to delete event $eventId',
    );
  }

  ///
  /// HELPERS
  ///

  EventDriftDto _formatEventDTO(Event row, Member? linkedMember) {
    return EventDriftDto(
      id: row.id,
      title: row.title,
      timeDate: row.timeDate,
      notes: row.notes,
      member: linkedMember != null
          ? MemberDriftDto(
              id: linkedMember.id,
              name: linkedMember.name,
              hexColor: linkedMember.hexColor,
              avatarKey: linkedMember.avatarKey,
            )
          : null,
    );
  }
}
