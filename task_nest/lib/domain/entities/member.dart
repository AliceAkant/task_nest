import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/domain/enums/member_theme.dart';
import 'package:task_nest/domain/helpers/enum_converters.dart';

class Member {
  final int? id;
  final String name;
  final MemberTheme theme;
  final Avatar avatar;

  Member({
    required this.id,
    required this.name,
    required this.avatar,
    required this.theme,
  });

  Member.fromEntity(
    String avatarKey,
    String colorHex, {
    required this.id,
    required this.name,
  }) : avatar = EnumConverters.avatarFromKey(avatarKey),
       theme = EnumConverters.memberThemeFromHexColor(colorHex);

  @override
  String toString() {
    return 'Member('
        'id: ${id ?? "-"}, '
        'name: $name, '
        'theme: ${theme.toString()}, '
        'avatar: ${avatar.toString()}'
        ')';
  }
}
