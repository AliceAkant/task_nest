import 'package:flutter/material.dart';

// MAIN
const Color M_COLOR_ROSE = Color(0xFFF8BBD0);
const Color M_COLOR_MINT = Color(0xFFB2DFDB);
const Color M_COLOR_PEACH = Color(0xFFFFCCBC);
const Color M_COLOR_SKY = Color(0xFFB3E5FC);
const Color M_COLOR_LILAC = Color(0xFFE1BEE7);
const Color M_COLOR_LEMON = Color(0xFFFFF9C4);
const Color M_COLOR_NONE = Colors.transparent;

// BORDER
const Color M_BORDER_ROSE = Color(0xFFF48FB1);
const Color M_BORDER_MINT = Color(0xFF80CBC4);
const Color M_BORDER_PEACH = Color(0xFFFFAB91);
const Color M_BORDER_SKY = Color(0xFF81D4FA);
const Color M_BORDER_LILAC = Color(0xFFCE93D8);
const Color M_BORDER_LEMON = Color(0xFFFFF176);
const Color M_BORDER_NONE = Color(0xFFBCC1CA);

// DARK THEME SCHEDULE COLORS
const Color SCHEDULE_BG_ROSE = Color(0xFF4B2C3D);
const Color SCHEDULE_BG_MINT = Color(0xFF2C4B48);
const Color SCHEDULE_BG_PEACH = Color(0xFF4B3A2C);
const Color SCHEDULE_BG_SKY = Color(0xFF2C3D4B);
const Color SCHEDULE_BG_LILAC = Color(0xFF3D2C4B);
const Color SCHEDULE_BG_LEMON = Color(0xFF4B4B2C);
const Color SCHEDULE_BG_NONE = Color(0xFF1E293B);

enum MemberTheme { none, rose, mint, peach, sky, lilac, lemon }

extension MemberThemeExtension on MemberTheme {
  Color get color {
    switch (this) {
      case MemberTheme.rose:
        return M_COLOR_ROSE;
      case MemberTheme.mint:
        return M_COLOR_MINT;
      case MemberTheme.peach:
        return M_COLOR_PEACH;
      case MemberTheme.sky:
        return M_COLOR_SKY;
      case MemberTheme.lilac:
        return M_COLOR_LILAC;
      case MemberTheme.lemon:
        return M_COLOR_LEMON;
      case MemberTheme.none:
        return M_COLOR_NONE;
    }
  }

  Color scheduleBG(ThemeMode theme) {
    if (theme == ThemeMode.dark) {
      switch (this) {
        case MemberTheme.rose:
          return SCHEDULE_BG_ROSE;
        case MemberTheme.mint:
          return SCHEDULE_BG_MINT;
        case MemberTheme.peach:
          return SCHEDULE_BG_PEACH;
        case MemberTheme.sky:
          return SCHEDULE_BG_SKY;
        case MemberTheme.lilac:
          return SCHEDULE_BG_LILAC;
        case MemberTheme.lemon:
          return SCHEDULE_BG_LEMON;
        case MemberTheme.none:
          return SCHEDULE_BG_NONE;
      }
    } else {
      if (this == MemberTheme.none) {
        return M_BORDER_NONE.withAlpha(60);
      }
      return color.withAlpha(100);
    }
  }

  Color get borderColor {
    switch (this) {
      case MemberTheme.rose:
        return M_BORDER_ROSE;
      case MemberTheme.mint:
        return M_BORDER_MINT;
      case MemberTheme.peach:
        return M_BORDER_PEACH;
      case MemberTheme.sky:
        return M_BORDER_SKY;
      case MemberTheme.lilac:
        return M_BORDER_LILAC;
      case MemberTheme.lemon:
        return M_BORDER_LEMON;
      case MemberTheme.none:
        return M_BORDER_NONE;
    }
  }
}
