import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/presentation/enum/app_svg.dart';
import 'package:task_nest/presentation/enum/button_kind.dart';
import 'package:task_nest/presentation/enum/popup_result.dart';
import 'package:task_nest/presentation/enum/popup_style.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/assets_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/bordered_button.dart';
import 'package:task_nest/presentation/widgets/rounded_button.dart';
import 'package:task_nest/presentation/widgets/views/base_snack_bar.dart';

class PopupHelper {
  static void showErrorSnackBar(BuildContext context, {String? errorMessage}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      BaseSnackbar(
        type: SnackBarType.error,
        title: context.tr(LocaleKeys.error_snack_title),
        message: errorMessage ?? context.tr(LocaleKeys.error_snack_message),
      ),
    );
  }

  static Future showTwoActions(
    BuildContext context, {
    required String title,
    required String message,
    required String submitText,
    required String cancelText,
    AppSvg? iconSource,
    Function()? onSubmit,
    Function()? onCancel,
    PopupStyle style = PopupStyle.base,
    double? hPadding,
    bool closeByOverlayTap = true,
    double? maxHeight,
  }) => _showDialog(
    context,
    content: _actionDialog(
      context,
      title: title,
      message: message,
      iconSource: iconSource,
      submitText: submitText,
      cancelText: cancelText,
      style: style,
      onSubmit: onSubmit,
      onCancel: onCancel,
    ),
    hPadding: hPadding,
    maxHeight: maxHeight,
    closeByOverlayTap: closeByOverlayTap,
  );

  static Future showOneAction(
    BuildContext context, {
    required String title,
    required String message,
    required String submitText,
    AppSvg? iconSource,
    Function()? onSubmit,
    PopupStyle style = PopupStyle.base,
    double? hPadding,
    bool closeByOverlayTap = true,
    double? maxHeight,
  }) => _showDialog(
    context,
    content: _actionDialog(
      context,
      title: title,
      message: message,
      iconSource: iconSource,
      submitText: submitText,
      style: style,
      onSubmit: onSubmit,
    ),
    hPadding: hPadding,
    maxHeight: maxHeight,
    closeByOverlayTap: closeByOverlayTap,
  );

  static Future showLoading(
    BuildContext context, {
    required String message,
    double? hPadding,
    bool closeByOverlayTap = false,
    double? maxHeight,
  }) => _showDialog(
    context,
    content: Padding(
      padding: const EdgeInsets.all(AppSizes.popupContentHGap),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSizes.spacing16),
          const CircularProgressIndicator(),
          const SizedBox(height: AppSizes.spacing16),
          BaseText(
            message,
            align: TextAlign.center,
            maxLines: 5,
            height: 1.2,
            fontWeight: TypographyConst.wSemiBold,
            fontSize: TypographyConst.labelStandart,
          ),
        ],
      ),
    ),
    hPadding: hPadding,
    maxHeight: maxHeight,
    closeByOverlayTap: closeByOverlayTap,
  );

  ///
  /// HELPERS
  ///

  static Future _showDialog(
    BuildContext context, {
    required Widget content,
    double? hPadding,
    double? maxHeight,
    bool closeByOverlayTap = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: closeByOverlayTap,
      barrierColor: Colors.black.withAlpha(140),
      builder: (context) => _generalDialog(
        context,
        content,
        hPadding: hPadding,
        maxHeight: maxHeight,
      ),
    );
  }

  static Widget _generalDialog(
    BuildContext context,
    Widget content, {
    double? hPadding,
    double? maxHeight,
  }) {
    return Dialog(
      elevation: 12,
      shadowColor: context.colors.defaultShadow,
      insetPadding: EdgeInsets.symmetric(
        horizontal: hPadding ?? AppSizes.popupHGap,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.popupRadius),
      ),
      backgroundColor: context.colors.background,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? AppSizes.popupMaxHeight,
        ),
        child: SingleChildScrollView(child: content),
      ),
    );
  }

  static Widget _actionDialog(
    BuildContext context, {
    required String title,
    required String message,
    AppSvg? iconSource,
    required String submitText,
    String? cancelText,
    PopupStyle style = PopupStyle.base,
    Function()? onSubmit,
    Function()? onCancel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.popupContentVGap,
        horizontal: AppSizes.popupContentHGap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconSource != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
              child: AssetsHelper.getSvgImage(
                iconSource,
                height: AppSizes.size56,
                color: style == PopupStyle.base
                    ? context.colors.purple
                    : context.colors.error,
              ),
            ),
          BaseText(
            title,
            align: TextAlign.center,
            maxLines: 5,
            height: 1.2,
            fontWeight: TypographyConst.wSemiBold,
            fontSize: TypographyConst.labelLarge,
          ),
          const SizedBox(height: AppSizes.spacing8),
          BaseText(
            message,
            maxLines: 20,
            align: TextAlign.center,
            height: 1.4,
            fontSize: TypographyConst.labelMedium,
          ),
          const SizedBox(height: AppSizes.spacing24),
          Row(
            children: [
              if (cancelText != null)
                Expanded(
                  child: BorderedButton(
                    textKey: cancelText,
                    kind: style == PopupStyle.base
                        ? ButtonKind.base
                        : ButtonKind.error,
                    onTap: () =>
                        onCancel?.call() ??
                        Navigator.pop(context, PopupResult.cancel),
                  ),
                ),
              if (cancelText != null) const SizedBox(width: AppSizes.spacing8),
              Expanded(
                child: RoundedButton(
                  textKey: submitText,
                  kind: style == PopupStyle.base
                      ? ButtonKind.base
                      : ButtonKind.error,
                  onTap: () =>
                      onSubmit?.call() ??
                      Navigator.pop(context, PopupResult.submit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
