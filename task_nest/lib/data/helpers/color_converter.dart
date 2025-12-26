import 'dart:ui';

class ColorConverter {
  static Color fromHex(String hexString) {
    hexString = hexString.replaceFirst('#', '');
    return Color(int.parse(hexString, radix: 16));
  }

  static String toHex(Color color) {
    final hex = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#$hex';
  }
}
