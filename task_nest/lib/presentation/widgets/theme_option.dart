import 'package:flutter/material.dart';
import 'package:task_nest/domain/enums/member_theme.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/assets_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';

class ThemeOption extends StatelessWidget {
  final bool isSelected;
  final MemberTheme theme;
  final VoidCallback onTap;

  const ThemeOption({
    required this.isSelected,
    required this.theme,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacing4),
        width: AppSizes.size52,
        height: AppSizes.size52,
        decoration: BoxDecoration(
          color: theme.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? context.colors.borderFocused
                : context.colors.borderSecondary,
            width: AppSizes.border3,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            if (theme == MemberTheme.none)
              AssetsHelper.getSvgImage('no_avatar', height: AppSizes.size24),
          ],
        ),
      ),
    );
  }
}
