import 'package:task_nest/data/dto_models/local/member_drift_dto.dart';
import 'package:task_nest/domain/entities/event.dart';

class EventDriftDto {
  final int id;
  final String title;
  final DateTime timeDate;
  final String? notes;
  final MemberDriftDto? member;

  EventDriftDto({
    required this.id,
    required this.title,
    required this.timeDate,
    required this.notes,
    this.member,
  });

  EventDriftDto copyWith({
    int? id,
    String? title,
    DateTime? timeDate,
    String? notes,
    MemberDriftDto? member,
  }) {
    return EventDriftDto(
      id: id ?? this.id,
      title: title ?? this.title,
      timeDate: timeDate ?? this.timeDate,
      notes: notes ?? this.notes,
      member: member ?? this.member,
    );
  }

  Event toEntity() => Event(
    id: id,
    title: title,
    dateTime: timeDate,
    member: member?.toEntity(),
    notes: notes,
  );

  factory EventDriftDto.fromEntity(Event event) {
    return EventDriftDto(
      id: event.id ?? 0, // autoincrement
      title: event.title,
      timeDate: event.dateTime,
      notes: event.notes,
      member: event.member != null
          ? MemberDriftDto.fromEntity(event.member!)
          : null,
    );
  }
}
