import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/theme/typography.dart';

enum BaseTextType { normal, primary, secondary }

class BaseText extends StatelessWidget {
  final String text;
  final bool localized;
  final Color? color;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;
  final TextAlign align;
  final double? fontSize;
  final TextOverflow? overflow;
  final double? letterSpacing;
  final String? fontFamily;
  final int? maxLines;
  final double? height;
  final TextStyle? style;

  final BaseTextType type;

  const BaseText(
    this.text, {
    super.key,
    this.localized = true,
    this.color,
    this.fontWeight,
    this.decoration,
    this.align = TextAlign.start,
    this.fontSize,
    this.overflow = TextOverflow.ellipsis,
    this.letterSpacing,
    this.fontFamily,
    this.maxLines,
    this.height,
    this.style,
  }) : type = BaseTextType.normal;

  const BaseText.primary(
    this.text, {
    super.key,
    this.localized = true,
    this.fontWeight,
    this.decoration,
    this.align = TextAlign.start,
    this.fontSize,
    this.overflow = TextOverflow.ellipsis,
    this.letterSpacing,
    this.fontFamily,
    this.maxLines,
    this.height,
    this.style,
  }) : color = null,
       type = BaseTextType.primary;

  const BaseText.secondary(
    this.text, {
    super.key,
    this.localized = true,
    this.fontWeight,
    this.decoration,
    this.align = TextAlign.start,
    this.fontSize,
    this.overflow = TextOverflow.ellipsis,
    this.letterSpacing,
    this.fontFamily,
    this.maxLines,
    this.height,
    this.style,
  }) : color = null,
       type = BaseTextType.secondary;

  @override
  Widget build(BuildContext context) {
    final textColor = _getTextColor(context);

    return Text(
      key: key,
      localized ? context.tr(text) : text,
      overflow: overflow ?? TextOverflow.ellipsis,
      maxLines: maxLines,
      textAlign: align,
      style: TextStyle(
        decoration: decoration ?? TextDecoration.none,
        fontFamily: fontFamily ?? TypographyConst.fontFamily,
        height: height,
        color: textColor,
        fontWeight: fontWeight ?? TypographyConst.wRegular,
        fontSize: fontSize ?? TypographyConst.labelStandart,
        letterSpacing: letterSpacing,
      ),
    );
  }

  Color _getTextColor(BuildContext context) {
    switch (type) {
      case BaseTextType.normal:
        return color ?? context.colors.labelPrimary;
      case BaseTextType.primary:
        return context.colors.labelPrimary;
      case BaseTextType.secondary:
        return context.colors.labelSecondary;
    }
  }
}
