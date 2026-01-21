import 'package:task_nest/presentation/enum/app_svg.dart';

enum Avatar {
  none,
  dog,
  cat,
  hamster,
  snail,
  sheep,
  mouse,
  parrot,
  tiger,
  duck,
  giraffe,
}

extension AvatarExtension on Avatar {
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

  String get icon {
    switch (this) {
      case Avatar.none:
        return "no_avatar";
      case Avatar.dog:
        return "dog";
      case Avatar.cat:
        return "cat";
      case Avatar.hamster:
        return "hamster";
      case Avatar.snail:
        return "snail";
      case Avatar.sheep:
        return "sheep";
      case Avatar.mouse:
        return "mouse";
      case Avatar.parrot:
        return "parrot";
      case Avatar.tiger:
        return "tiger";
      case Avatar.duck:
        return "duck";
      case Avatar.giraffe:
        return "giraffe";
    }
  }

  String get storeKey {
    switch (this) {
      case Avatar.none:
        return "no";
      case Avatar.dog:
        return "avatar_dog";
      case Avatar.cat:
        return "avatar_cat";
      case Avatar.hamster:
        return "avatar_hamster";
      case Avatar.snail:
        return "avatar_snail";
      case Avatar.sheep:
        return "avatar_sheep";
      case Avatar.mouse:
        return "avatar_mouse";
      case Avatar.parrot:
        return "avatar_parrot";
      case Avatar.tiger:
        return "avatar_tiger";
      case Avatar.duck:
        return "avatar_duck";
      case Avatar.giraffe:
        return "avatar_giraffe";
    }
  }
}
