import 'package:flutter/material.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';

class UiHelper {
  static InputDecoration inputDecoration(
    BuildContext context, {
    Widget? label,
    Widget? hint,
    bool isValid = true,
    TextStyle? errorStyle,
    Color? fillColor,
    double? verticalSpacing,
    double? horizontalSpacing,
    Widget? suffixIcon,
    bool isMultiline = false,
  }) {
    final vSpace = verticalSpacing ?? AppSizes.spacing8;
    return InputDecoration(
      border: _border(context.colors.borderPrimary),
      enabledBorder: _border(context.colors.borderPrimary),
      focusedBorder: _border(context.colors.borderFocused, width: 2),
      errorBorder: _border(context.colors.borderError, width: 2),
      contentPadding: isMultiline
          // Don't touch, fixed bug with multilines input (text out of border)
          // (top: 0, bottom: 12 - minimum)
          ? EdgeInsets.fromLTRB(vSpace, 4, vSpace, 16)
          : EdgeInsets.symmetric(
              horizontal: horizontalSpacing ?? AppSizes.inputHGap,
              vertical: vSpace,
            ),
      label: label,
      hint: hint,
      errorText: isValid ? null : "",
      errorStyle: errorStyle ?? TextStyle(height: 0.01),
      filled: true,
      fillColor: fillColor ?? context.colors.background,
      suffixIcon: suffixIcon,
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSizes.inputRadius),
        ),
        borderSide: BorderSide(color: color, width: width),
      );
}
