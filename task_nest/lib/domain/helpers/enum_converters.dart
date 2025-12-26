import 'package:task_nest/data/helpers/color_converter.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/domain/enums/member_theme.dart';

class EnumConverters {
  static Avatar avatarFromKey(String key) {
    switch (key) {
      case "avatar_dog":
        return Avatar.dog;
      case "avatar_cat":
        return Avatar.cat;
      case "avatar_hamster":
        return Avatar.hamster;
      case "avatar_snail":
        return Avatar.snail;
      case "avatar_sheep":
        return Avatar.sheep;
      case "avatar_mouse":
        return Avatar.mouse;
      case "avatar_parrot":
        return Avatar.parrot;
      case "avatar_tiger":
        return Avatar.tiger;
      case "avatar_duck":
        return Avatar.duck;
      case "avatar_giraffe":
        return Avatar.giraffe;
      default:
        return Avatar.none;
    }
  }

  static MemberTheme memberThemeFromHexColor(String hexColor) {
    var color = ColorConverter.fromHex(hexColor);

    if (color == M_COLOR_ROSE) return MemberTheme.rose;
    if (color == M_COLOR_MINT) return MemberTheme.mint;
    if (color == M_COLOR_PEACH) return MemberTheme.peach;
    if (color == M_COLOR_SKY) return MemberTheme.sky;
    if (color == M_COLOR_LILAC) return MemberTheme.lilac;
    if (color == M_COLOR_LEMON) return MemberTheme.lemon;

    return MemberTheme.none;
  }
}
