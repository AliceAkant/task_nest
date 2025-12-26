import 'package:flutter/material.dart';
import 'package:task_nest/presentation/enum/button_kind.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';

class BorderedButton extends StatelessWidget {
  final String textKey;
  final VoidCallback? onTap;
  final ButtonKind kind;
  final bool isEnabled;
  final Color? textColor;
  final Color? borderColor;
  final double? height;

  const BorderedButton({
    super.key,
    required this.textKey,
    required this.onTap,
    this.kind = ButtonKind.base,
    this.isEnabled = true,
    this.textColor,
    this.borderColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? AppSizes.buttonHeight,
      child: TappableBox(
        splashColor: _getSplashColor(context),
        onTap: () {
          if (isEnabled) {
            onTap?.call();
          }
        },
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSizes.buttonRadius),
        ),
        border: Border.all(color: _getBorderColor(context), width: 2),
        child: Center(
          child: BaseText(
            textKey,
            fontWeight: TypographyConst.wSemiBold,
            fontSize: TypographyConst.labelMedium,
            color: _getTextColor(context),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(BuildContext context) {
    switch (kind) {
      case ButtonKind.base:
        return isEnabled
            ? (borderColor ?? context.colors.borderFocused)
            : context.colors.borderDisabled;

      case ButtonKind.error:
        return isEnabled
            ? context.colors.borderError
            : context.colors.borderDisabled;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (kind) {
      case ButtonKind.base:
        return isEnabled
            ? (textColor ?? context.colors.buttonPrimary)
            : context.colors.labelDisable;

      case ButtonKind.error:
        return isEnabled ? context.colors.error : context.colors.labelDisable;
    }
  }

  Color _getSplashColor(BuildContext context) {
    switch (kind) {
      case ButtonKind.base:
        return isEnabled ? context.colors.defaultSplash : Colors.transparent;

      case ButtonKind.error:
        return isEnabled ? context.colors.redSplash : Colors.transparent;
    }
  }
}
