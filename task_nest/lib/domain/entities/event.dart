import 'package:task_nest/domain/entities/member.dart';

class Event {
  final int? id;
  final String title;
  final DateTime dateTime;
  final Member? member;
  final String? notes;

  Event({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.member,
    required this.notes,
  });

  @override
  String toString() {
    return 'Event('
        'id: ${id ?? "-"}, '
        'title: $title, '
        'dateTime: ${dateTime.toIso8601String()}, '
        'member: ${member?.name ?? "none"}, '
        'notes: ${notes ?? "none"}'
        ')';
  }
}
