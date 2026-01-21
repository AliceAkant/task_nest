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

  static final List<Avatar> _filteredAvatars = Avatar.values
      .where((a) => a != Avatar.none)
      .toList();

  @override
  Widget build(BuildContext context) {
    final avatarsList = excludeNone ? _filteredAvatars : Avatar.values;
    return Wrap(
      runSpacing: AppSizes.spacing4,
      spacing: AppSizes.spacing8,
      alignment: center ? WrapAlignment.center : WrapAlignment.start,
      children: avatarsList
          .map(
            (a) => AvatarOption(
              key: ValueKey(a),
              isSelected: (seclectedItem ?? avatarsList.first) == a,
              asset: a.asset,
              onTap: () => onSelect?.call(a),
            ),
          )
          .toList(),
    );
  }
}
