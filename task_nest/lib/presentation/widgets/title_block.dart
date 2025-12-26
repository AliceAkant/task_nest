import 'package:flutter/material.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';

class TitleBlock extends StatelessWidget {
  final String titleKey;
  final Widget child;
  final bool outlined;

  const TitleBlock({
    super.key,
    required this.titleKey,
    required this.child,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseText.secondary(titleKey, fontWeight: TypographyConst.wSemiBold),
        const SizedBox(height: AppSizes.spacing8),
        outlined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppSizes.barRadius),
                  ),
                  border: Border.all(
                    width: AppSizes.border1,
                    color: context.colors.borderSecondary,
                  ),
                ),
                child: child,
              )
            : child,
      ],
    );
  }
}
