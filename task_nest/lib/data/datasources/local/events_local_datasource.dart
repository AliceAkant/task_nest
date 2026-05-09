import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/data/datasources/datasource_helper.dart';
import 'package:task_nest/data/dto_models/local/event_drift_dto.dart';
import 'package:task_nest/data/dto_models/local/member_drift_dto.dart';
import 'package:task_nest/infrastructure/storage/drift/app_database.dart';
import 'package:task_nest/core/extensions/date_time_extension.dart';

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

  Future<Either<Failure, Map<DateTime, int>>> getEventsCount(
    DateTime start,
    int monthsCount,
  ) async {
    final startDate = start.dateOnly;
    final safeMonths = monthsCount < 0 ? 0 : monthsCount;
    final lastDate = DateTime(
      startDate.year,
      startDate.month + safeMonths,
      startDate.day,
    ).endOfDay;

    return DataSourceHelper.executeSafe(
      action: () async {
        // Fetch raw datetimes and group by date in Dart.
        // SQL groupBy on timeDate would group by exact time, not just date.
        final query = db.selectOnly(db.events)
          ..addColumns([db.events.timeDate])
          ..where(db.events.timeDate.isBetweenValues(startDate, lastDate));

        final rows = await query.get();

        final resultMap = <DateTime, int>{};
        for (final row in rows) {
          final dt = row.read(db.events.timeDate);
          if (dt != null) {
            final key = dt.dateOnly;
            resultMap[key] = (resultMap[key] ?? 0) + 1;
          }
        }

        return resultMap;
      },
      errorTitle:
          "Failed to get events count between ${startDate.toString()} - ${lastDate.toString()}",
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
