import 'package:flutter/material.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/widgets/avatar_option.dart';

class AvatarSelectionView extends StatelessWidget {
  final bool center;
  final bool excludeNone;
  final Avatar? seclectedItem;
  final ValueChanged<Avatar>? onSelect;

  const AvatarSelectionView({
    this.center = false,
    this.excludeNone = false,
    this.seclectedItem,
    this.onSelect,
    super.key,
  });

  List<Avatar> get _avatars {
    var allAvatars = <Avatar>[...Avatar.values];
    allAvatars.remove(Avatar.none);

    return allAvatars;
  }

  @override
  Widget build(BuildContext context) {
    final avatarsList = excludeNone ? _avatars : Avatar.values;
    return Wrap(
      runSpacing: AppSizes.spacing4,
      spacing: AppSizes.spacing8,
      alignment: center ? WrapAlignment.center : WrapAlignment.start,
      children: _avatars
          .map(
            (a) => AvatarOption(
              isSelected: (seclectedItem ?? avatarsList.first) == a,
              asset: a.icon,
              onTap: () => onSelect?.call(a),
            ),
          )
          .toList(),
    );
  }
}
