import 'package:task_nest/domain/entities/user_profile.dart';
import 'package:task_nest/domain/entities/user_settings.dart';
import 'package:task_nest/domain/enums/avatar.dart';

class UserDto {
  final String name;
  final String avatarKey;
  final bool showOnlyUserEvents;

  UserDto({
    required this.name,
    required this.avatarKey,
    this.showOnlyUserEvents = false,
  });

  factory UserDto.fromEntity(UserProfile user) {
    return UserDto(
      name: user.name,
      avatarKey: user.avatar.storeKey,
      showOnlyUserEvents: user.settings.showOnlyMyEvents,
    );
  }

  UserProfile toEntity() => UserProfile.fromDTO(
    avatarKey,
    name: name,
    settings: UserSettings(showOnlyMyEvents: showOnlyUserEvents),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'avatarKey': avatarKey,
    'showOnlyUserEvents': showOnlyUserEvents,
  };

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      name: json['name'] as String,
      avatarKey: json['avatarKey'] as String,
      showOnlyUserEvents: json['showOnlyUserEvents'] as bool? ?? false,
    );
  }
}
