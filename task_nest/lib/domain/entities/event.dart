import 'package:equatable/equatable.dart';
import 'package:task_nest/domain/entities/member.dart';

class Event extends Equatable {
  static const Duration defaultDuration = Duration(minutes: 30);

  final int? id;
  final String title;
  final DateTime dateTime;
  final Duration duration;
  final Member? member;
  final String? notes;

  const Event({
    required this.id,
    required this.title,
    required this.dateTime,
    this.duration = defaultDuration,
    required this.member,
    required this.notes,
  });

  DateTime get endDateTime => dateTime.add(duration);

  @override
  List<Object?> get props => [id, title, dateTime, duration, member, notes];

  @override
  String toString() {
    return 'Event('
        'id: ${id ?? "-"}, '
        'title: $title, '
        'dateTime: ${dateTime.toIso8601String()}, '
        'duration: ${duration.inMinutes}min, '
        'member: ${member?.name ?? "none"}, '
        'notes: ${notes ?? "none"}'
        ')';
  }
}
