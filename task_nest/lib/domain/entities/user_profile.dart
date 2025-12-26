import 'package:task_nest/domain/entities/user_settings.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/domain/helpers/enum_converters.dart';

class UserProfile {
  final String name;
  final Avatar avatar;
  final UserSettings settings;

  UserProfile({
    required this.name,
    required this.avatar,
    required this.settings,
  });

  UserProfile.fromDTO(
    String avatarKey, {
    required this.name,
    required this.settings,
  }) : avatar = EnumConverters.avatarFromKey(avatarKey);

  @override
  String toString() {
    return 'UserProfile('
        'name: $name, '
        'avatar: ${avatar.toString()}, '
        'settings: ${settings.toString()}'
        ')';
  }
}
