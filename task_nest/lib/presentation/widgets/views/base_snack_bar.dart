import 'package:flutter/material.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';

enum SnackBarType { info, success, error }

class BaseSnackbar extends SnackBar {
  BaseSnackbar({
    required String title,
    SnackBarType type = SnackBarType.info,
    String? message,
    String? icon,
    double? bottomPadding,
    super.key,
  }) : super(
         behavior: SnackBarBehavior.floating,
         backgroundColor: Colors.transparent,
         elevation: 0,
         dismissDirection: DismissDirection.down,
         shape: const RoundedRectangleBorder(
           borderRadius: BorderRadius.all(
             Radius.circular(AppSizes.buttonRadius),
           ),
         ),
         padding: EdgeInsets.zero,
         margin: EdgeInsets.only(
           bottom: bottomPadding ?? AppSizes.bottomPadding,
           left: AppSizes.spacing16,
           right: AppSizes.spacing16,
         ),
         duration: const Duration(seconds: 3),
         content: _SnackBarContent(
           title: title,
           type: type,
           message: message,
           icon: icon,
         ),
       );
}

class _SnackBarContent extends StatelessWidget {
  final SnackBarType type;
  final String title;
  final String? message;
  final String? icon;

  const _SnackBarContent({
    required this.title,
    required this.type,
    this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = _SnackBarStyle.of(context, type);

    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing12,
          vertical: AppSizes.spacing4,
        ),
        decoration: BoxDecoration(
          color: style.backgroundColor,
          border: Border.all(
            width: type == SnackBarType.info
                ? AppSizes.border2
                : AppSizes.border1,
            color: style.borderColor,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(AppSizes.buttonRadius),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.spacing8),
              child: Icon(
                style.icon,
                size: AppSizes.size28,
                color: style.iconColor,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BaseText(
                    title,
                    fontSize: TypographyConst.labelMedium,
                    fontWeight: TypographyConst.wSemiBold,
                    color: style.iconColor,
                    localized: false,
                    maxLines: 2,
                    height: 1.1,
                  ),
                  if (message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.spacing2),
                      child: BaseText(
                        message!,
                        fontSize: TypographyConst.labelSmall,
                        color: style.iconColor,
                        localized: false,
                        maxLines: 3,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.spacing4),
            Icon(Icons.close, size: AppSizes.size28, color: style.iconColor),
          ],
        ),
      ),
    );
  }
}

class _SnackBarStyle {
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final Color backgroundColor;

  const _SnackBarStyle({
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.backgroundColor,
  });

  static _SnackBarStyle of(BuildContext context, SnackBarType type) {
    switch (type) {
      case SnackBarType.info:
        return _SnackBarStyle(
          icon: Icons.info_outline,
          iconColor: context.colors.labelPrimary,
          borderColor: context.colors.borderPrimary,
          backgroundColor: context.colors.background,
        );
      case SnackBarType.success:
        return _SnackBarStyle(
          icon: Icons.check_circle_outline,
          iconColor: context.colors.success,
          borderColor: context.colors.success,
          backgroundColor: context.colors.success.withAlpha(20),
        );
      case SnackBarType.error:
        return _SnackBarStyle(
          icon: Icons.highlight_off,
          iconColor: context.colors.error,
          borderColor: context.colors.borderError,
          backgroundColor: context.colors.error.withAlpha(20),
        );
    }
  }
}
