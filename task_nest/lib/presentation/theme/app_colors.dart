import 'package:flutter/material.dart';

const Color DEFAULT_BG_COLOR_LIGHT = Colors.white;
const Color DEFAULT_BG_COLOR_DARK = Color(0xFF0F172A);

class AppColors extends ThemeExtension<AppColors> {
  static Color getDefaultBGColor(ThemeMode mode) =>
      mode == ThemeMode.dark ? DEFAULT_BG_COLOR_DARK : DEFAULT_BG_COLOR_LIGHT;

  final Color background;

  // General
  final Color purple;
  final Color lightPurple40;
  final Color lightGrey;
  final Color lightGrey150;
  final Color error;
  final Color success;
  final Color disable;

  // Labels
  final Color labelPrimary;
  final Color labelSecondary;
  final Color labelDisable;
  final Color labelHint;

  // Buttons
  final Color buttonText;
  final Color buttonPrimary;
  final Color buttonDisabled;

  // Borders
  final Color borderPrimary;
  final Color borderFocused;
  final Color borderError;
  final Color borderDisabled;
  final Color borderSecondary;

  // Extra
  final Color defaultSplash;
  final Color redSplash;
  final Color defaultShadow;

  const AppColors({
    required this.background,
    required this.purple,
    required this.lightPurple40,
    required this.lightGrey,
    required this.lightGrey150,
    required this.error,
    required this.success,
    required this.disable,
    required this.labelPrimary,
    required this.labelSecondary,
    required this.labelDisable,
    required this.labelHint,
    required this.buttonText,
    required this.buttonPrimary,
    required this.buttonDisabled,
    required this.borderPrimary,
    required this.borderFocused,
    required this.borderError,
    required this.borderDisabled,
    required this.borderSecondary,
    required this.defaultSplash,
    required this.redSplash,
    required this.defaultShadow,
  });

  @override
  AppColors copyWith({
    Color? background,
    Color? purple,
    Color? lightPurple40,
    Color? lightGrey,
    Color? lightGrey150,
    Color? error,
    Color? success,
    Color? disable,
    Color? labelPrimary,
    Color? labelSecondary,
    Color? labelDisable,
    Color? labelHint,
    Color? buttonText,
    Color? buttonPrimary,
    Color? buttonDisabled,
    Color? borderPrimary,
    Color? borderFocused,
    Color? borderError,
    Color? borderDisabled,
    Color? borderSecondary,
    Color? defaultSplash,
    Color? redSplash,
    Color? defaultShadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      purple: purple ?? this.purple,
      lightPurple40: lightPurple40 ?? this.lightPurple40,
      lightGrey: lightGrey ?? this.lightGrey,
      lightGrey150: lightGrey150 ?? this.lightGrey150,
      error: error ?? this.error,
      success: success ?? this.success,
      disable: disable ?? this.disable,
      labelPrimary: labelPrimary ?? this.labelPrimary,
      labelSecondary: labelSecondary ?? this.labelSecondary,
      labelDisable: labelDisable ?? this.labelDisable,
      labelHint: labelHint ?? this.labelHint,
      buttonText: buttonText ?? this.buttonText,
      buttonPrimary: buttonPrimary ?? this.buttonPrimary,
      buttonDisabled: buttonDisabled ?? this.buttonDisabled,
      borderPrimary: borderPrimary ?? this.borderPrimary,
      borderFocused: borderFocused ?? this.borderFocused,
      borderError: borderError ?? this.borderError,
      borderDisabled: borderDisabled ?? this.borderDisabled,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      defaultSplash: defaultSplash ?? this.defaultSplash,
      redSplash: redSplash ?? this.redSplash,
      defaultShadow: defaultShadow ?? this.defaultShadow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      lightPurple40: Color.lerp(lightPurple40, other.lightPurple40, t)!,
      lightGrey: Color.lerp(lightGrey, other.lightGrey, t)!,
      lightGrey150: Color.lerp(lightGrey150, other.lightGrey150, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      disable: Color.lerp(disable, other.disable, t)!,
      labelPrimary: Color.lerp(labelPrimary, other.labelPrimary, t)!,
      labelSecondary: Color.lerp(labelSecondary, other.labelSecondary, t)!,
      labelDisable: Color.lerp(labelDisable, other.labelDisable, t)!,
      labelHint: Color.lerp(labelHint, other.labelHint, t)!,
      buttonText: Color.lerp(buttonText, other.buttonText, t)!,
      buttonPrimary: Color.lerp(buttonPrimary, other.buttonPrimary, t)!,
      buttonDisabled: Color.lerp(buttonDisabled, other.buttonDisabled, t)!,
      borderPrimary: Color.lerp(borderPrimary, other.borderPrimary, t)!,
      borderFocused: Color.lerp(borderFocused, other.borderFocused, t)!,
      borderError: Color.lerp(borderError, other.borderError, t)!,
      borderDisabled: Color.lerp(borderDisabled, other.borderDisabled, t)!,
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t)!,
      defaultSplash: Color.lerp(defaultSplash, other.defaultSplash, t)!,
      redSplash: Color.lerp(redSplash, other.redSplash, t)!,
      defaultShadow: Color.lerp(defaultShadow, other.defaultShadow, t)!,
    );
  }

  static const light = AppColors(
    background: DEFAULT_BG_COLOR_LIGHT,
    purple: Color(0xFF636AE8),
    lightPurple40: Color(0x28636AE8),
    lightGrey: Color(0xFFbcc1ca),
    lightGrey150: Color(0x96bcc1ca),
    error: Color(0xFFc3272b),
    success: Color(0xFF22C55E),
    disable: Color(0xFFE0E0E0),
    labelPrimary: Color(0xFF000000),
    labelSecondary: Color(0xFF565d6d),
    labelDisable: Color(0xFF757575),
    labelHint: Color(0xFFbcc1ca),
    buttonText: Color(0xFFFFFFFF),
    buttonPrimary: Color(0xFF636AE8),
    buttonDisabled: Color(0xFFE0E0E0),
    borderPrimary: Color(0xFFe1e1e1),
    borderFocused: Color(0xFF636AE8),
    borderError: Color(0xFFc3272b),
    borderDisabled: Color(0xFF757575),
    borderSecondary: Color(0x96bcc1ca),
    defaultSplash: Color(0x96bcc1ca),
    redSplash: Color(0x50c3272b),
    defaultShadow: Color(0x96bcc1ca),
  );

  static const dark = AppColors(
    background: DEFAULT_BG_COLOR_DARK,
    purple: Color(0xFF636AE8),
    lightPurple40: Color(0x28636AE8),
    lightGrey: Color(0xFF94A3B8),
    lightGrey150: Color(0x6094A3B8),
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
    disable: Color(0xFF27272A),
    labelPrimary: Color(0xFFF1F5F9),
    labelSecondary: Color(0xFF94A3B8),
    labelDisable: Color(0xFF6B7280),
    labelHint: Color(0xFF94A3B8),
    buttonText: Color(0xFFFFFFFF),
    buttonPrimary: Color(0xFF636AE8),
    buttonDisabled: Color(0xFF27272A),
    borderPrimary: Color(0xFF334155),
    borderFocused: Color(0xFF636AE8),
    borderError: Color(0xFFEF4444),
    borderDisabled: Color(0xFF27272A),
    borderSecondary: Color(0x6094A3B8),
    defaultSplash: Color(0x6094A3B8),
    redSplash: Color(0x50EF4444),
    defaultShadow: Color(0x6094A3B8),
  );
}
