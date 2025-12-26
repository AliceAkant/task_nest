import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/assets_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';

class AppBarCreator {
  static AppBar generic(
    BuildContext context, {
    required String titleKey,
    String? actionIcon,
    bool actionDisabled = false,
    Function()? actionTap,
  }) {
    return AppBar(
      backgroundColor: context.colors.background,
      centerTitle: true,
      surfaceTintColor: context.colors.lightPurple40,
      title: BaseText(
        titleKey,
        fontWeight: TypographyConst.wBold,
        fontSize: TypographyConst.labelHeader,
      ),
      actions: [
        if (actionIcon != null && !actionDisabled)
          TappableBox(
            borderRadius: BorderRadius.circular(AppSizes.size24),
            onTap: () => actionTap?.call(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.spacing8,
                vertical: AppSizes.spacing8,
              ),
              margin: EdgeInsets.only(right: AppSizes.spacing4),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppSizes.barRadius),
                ),
              ),
              child: AssetsHelper.getSvgImage(
                actionIcon,
                height: AppSizes.size32,
                color: context.colors.labelPrimary,
              ),
            ),
          ),
      ],
    );
  }

  static AppBar modal(
    BuildContext context, {
    required String titleKey,
    Function()? onCloseTap,
    bool isCloseDisabled = false,
  }) {
    return AppBar(
      backgroundColor: context.colors.background,
      automaticallyImplyLeading: false,
      centerTitle: true,
      surfaceTintColor: context.colors.lightPurple40,
      actions: [
        IconButton(
          splashColor: isCloseDisabled ? Colors.transparent : null,
          highlightColor: isCloseDisabled ? Colors.transparent : null,
          icon: Icon(
            Icons.close,
            color: isCloseDisabled
                ? context.colors.labelDisable
                : context.colors.labelPrimary,
          ),
          iconSize: AppSizes.size28,
          onPressed: () {
            if (!isCloseDisabled) {
              if (onCloseTap != null) {
                onCloseTap.call();
              } else {
                context.pop();
              }
            }
          },
        ),
      ],
      title: BaseText(
        titleKey,
        fontWeight: TypographyConst.wBold,
        fontSize: TypographyConst.labelLarge,
      ),
    );
  }

  static AppBar secondary(
    BuildContext context, {
    required String titleKey,
    Function()? onBackTap,
    bool isBackDisabled = false,
  }) {
    return AppBar(
      backgroundColor: context.colors.background,
      automaticallyImplyLeading: false,
      centerTitle: true,
      surfaceTintColor: context.colors.lightPurple40,
      leading: IconButton(
        splashColor: isBackDisabled ? Colors.transparent : null,
        highlightColor: isBackDisabled ? Colors.transparent : null,
        icon: Icon(
          Icons.arrow_back,
          color: isBackDisabled
              ? context.colors.labelDisable
              : context.colors.labelPrimary,
        ),
        iconSize: AppSizes.size28,
        onPressed: () {
          if (!isBackDisabled) {
            if (onBackTap != null) {
              onBackTap.call();
            } else {
              context.pop();
            }
          }
        },
      ),
      title: BaseText(
        titleKey,
        fontWeight: TypographyConst.wBold,
        fontSize: TypographyConst.labelLarge,
      ),
    );
  }
}
