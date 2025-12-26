import 'package:flutter/material.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/assets_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';

class CheckableItem extends StatelessWidget {
  final String textKey;
  final String? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CheckableItem({
    super.key,
    required this.textKey,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing12),
        child: Row(
          children: [
            // Left icon
            if (icon != null) ...[
              AssetsHelper.getSvgImage(icon!, width: AppSizes.size24),
              const SizedBox(width: AppSizes.spacing4),
            ],

            // Text
            Expanded(child: BaseText.primary(textKey)),

            // Checkbox
            if (icon != null) const SizedBox(width: AppSizes.spacing4),
            isSelected
                ? AssetsHelper.getSvgImage(
                    'check_mark',
                    width: AppSizes.size18,
                    color: context.colors.purple,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
