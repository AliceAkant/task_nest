import 'package:flutter/material.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/rounded_button.dart';

class ErrorStateView extends StatelessWidget {
  final String? message;
  final Function()? onUpdateTap;

  const ErrorStateView({this.message, this.onUpdateTap, super.key});

  @override
  Widget build(BuildContext context) {
    final hasErrorMessage = message?.isNotEmpty ?? false;

    return Center(
      child: Padding(
        padding: const EdgeInsetsGeometry.symmetric(
          horizontal: AppSizes.spacing16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            BaseText.primary(
              LocaleKeys.general_load_failed_title,
              fontWeight: TypographyConst.wSemiBold,
              align: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: AppSizes.spacing4),
            BaseText.primary(
              LocaleKeys.general_error_reason,
              fontSize: TypographyConst.labelMedium,
              height: 1.2,
              maxLines: 4,
              align: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing4),
            if (hasErrorMessage)
              Padding(
                padding: EdgeInsets.only(top: AppSizes.spacing4),
                child: BaseText(
                  "[Reason: $message]",
                  localized: false,
                  fontSize: TypographyConst.labelSmall,
                  height: 1.2,
                  maxLines: 4,
                  color: context.colors.labelDisable,
                  align: TextAlign.center,
                ),
              ),
            const SizedBox(height: AppSizes.spacing12),
            IntrinsicWidth(
              child: RoundedButton(
                hPadding: AppSizes.spacing24,
                textKey: LocaleKeys.update,
                onTap: () => onUpdateTap?.call(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
