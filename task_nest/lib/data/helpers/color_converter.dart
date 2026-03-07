import 'dart:ui';

class ColorConverter {
  static Color fromHex(String hexString) {
    try {
      final cleaned = hexString.replaceFirst('#', '');
      return Color(int.parse(cleaned, radix: 16));
    } catch (_) {
      return const Color(0x00000000);
    }
  }

  static String toHex(Color color) {
    final hex = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#$hex';
  }
}
