import 'package:flutter/material.dart';
import 'package:task_nest/presentation/enum/app_svg.dart';
import 'package:task_nest/presentation/enum/button_kind.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/assets_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';

class BorderedIconButton extends StatelessWidget {
  final AppSvg iconSource;
  final VoidCallback? onTap;
  final ButtonKind kind;
  final Color? textColor;
  final Color? borderColor;
  final double? size;
  final bool isEnabled;

  const BorderedIconButton({
    super.key,
    required this.iconSource,
    required this.onTap,
    this.kind = ButtonKind.base,
    this.textColor,
    this.borderColor,
    this.size,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size ?? AppSizes.buttonHeight,
      width: size ?? AppSizes.buttonHeight,
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
          child: AssetsHelper.getSvgImage(
            iconSource,
            height: AppSizes.size24,
            color: _getIconColor(context),
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

  Color _getIconColor(BuildContext context) {
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
