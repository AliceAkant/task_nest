import 'package:flutter/material.dart';
import 'package:task_nest/domain/enums/member_theme.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/widgets/theme_option.dart';

class MemberThemeSelectionView extends StatelessWidget {
  final bool center;

  final MemberTheme? seclectedItem;
  final Function(MemberTheme)? onSelect;

  const MemberThemeSelectionView({
    this.seclectedItem,
    this.onSelect,
    this.center = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: AppSizes.spacing4,
      spacing: AppSizes.spacing8,
      alignment: center ? WrapAlignment.center : WrapAlignment.start,
      children: MemberTheme.values
          .map(
            (a) => ThemeOption(
              isSelected: (seclectedItem ?? MemberTheme.values.first) == a,
              theme: a,
              onTap: () => onSelect?.call(a),
            ),
          )
          .toList(),
    );
  }
}
