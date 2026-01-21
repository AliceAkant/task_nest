import 'package:flutter/material.dart';
import 'package:task_nest/presentation/enum/app_svg.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/assets_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';

class AvatarOption extends StatelessWidget {
  final bool isSelected;
  final AppSvg asset;
  final VoidCallback onTap;

  const AvatarOption({
    required this.isSelected,
    required this.asset,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RepaintBoundary(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacing4),
          width: AppSizes.size56,
          height: AppSizes.size56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? context.colors.borderFocused
                  : context.colors.borderSecondary,
              width: AppSizes.border3,
            ),
          ),
          child: AssetsHelper.getSvgImage(asset, height: AppSizes.size24),
        ),
      ),
    );
  }
}
