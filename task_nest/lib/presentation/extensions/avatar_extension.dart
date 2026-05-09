import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/presentation/enum/app_svg.dart';

extension AvatarAssetExtension on Avatar {
  AppSvg get asset {
    switch (this) {
      case Avatar.none:
        return AppSvg.noAvatar;
      case Avatar.dog:
        return AppSvg.dog;
      case Avatar.cat:
        return AppSvg.cat;
      case Avatar.hamster:
        return AppSvg.hamster;
      case Avatar.snail:
        return AppSvg.snail;
      case Avatar.sheep:
        return AppSvg.sheep;
      case Avatar.mouse:
        return AppSvg.mouse;
      case Avatar.parrot:
        return AppSvg.parrot;
      case Avatar.tiger:
        return AppSvg.tiger;
      case Avatar.duck:
        return AppSvg.duck;
      case Avatar.giraffe:
        return AppSvg.giraffe;
    }
  }
}
