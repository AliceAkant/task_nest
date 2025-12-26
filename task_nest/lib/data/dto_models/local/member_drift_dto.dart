import 'package:task_nest/data/helpers/color_converter.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/domain/enums/member_theme.dart';

class MemberDriftDto {
  final int id;
  final String name;
  final String hexColor;
  final String avatarKey;

  MemberDriftDto({
    required this.id,
    required this.name,
    required this.hexColor,
    required this.avatarKey,
  });

  MemberDriftDto copyWith({
    int? id,
    String? name,
    String? hexColor,
    String? avatarKey,
  }) {
    return MemberDriftDto(
      id: id ?? this.id,
      name: name ?? this.name,
      hexColor: hexColor ?? this.hexColor,
      avatarKey: avatarKey ?? this.avatarKey,
    );
  }

  Member toEntity() =>
      Member.fromEntity(avatarKey, hexColor, id: id, name: name);

  factory MemberDriftDto.fromEntity(Member member) => MemberDriftDto(
    id: member.id ?? 0, // autoincrement
    name: member.name,
    hexColor: ColorConverter.toHex(member.theme.color),
    avatarKey: member.avatar.storeKey,
  );
}
