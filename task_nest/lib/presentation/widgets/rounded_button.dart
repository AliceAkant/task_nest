import 'package:flutter/material.dart';
import 'package:task_nest/presentation/enum/button_kind.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';

class RoundedButton extends StatelessWidget {
  final String textKey;
  final Function()? onTap;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final ButtonKind kind;
  final double? hPadding;

  const RoundedButton({
    super.key,
    required this.textKey,
    required this.onTap,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.hPadding,
    this.kind = ButtonKind.base,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? AppSizes.buttonHeight,
      child: TappableBox(
        backgroundColor: _getBGColor(context),
        splashColor: _getSplashColor(context),
        onTap: () {
          if (isEnabled) {
            onTap?.call();
          }
        },
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSizes.buttonRadius),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: hPadding ?? 0),
            child: BaseText(
              textKey,
              fontWeight: TypographyConst.wSemiBold,
              fontSize: TypographyConst.labelMedium,
              color: isEnabled
                  ? (textColor ?? context.colors.buttonText)
                  : context.colors.labelDisable,
            ),
          ),
        ),
      ),
    );
  }

  Color _getBGColor(BuildContext context) {
    switch (kind) {
      case ButtonKind.base:
        return isEnabled
            ? (backgroundColor ?? context.colors.buttonPrimary)
            : context.colors.buttonDisabled;

      case ButtonKind.error:
        return isEnabled ? context.colors.error : context.colors.buttonDisabled;
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
