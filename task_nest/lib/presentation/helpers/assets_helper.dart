import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AssetsHelper {
  static Widget getSvgImage(
    String assetName, {
    double? height,
    double? width,
    BoxFit? fit,
    bool? selected,
    Color? color,
  }) {
    return assetName.isNotEmpty
        ? SvgPicture.asset(
            'assets/svg/$assetName.svg',
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            colorFilter: color != null
                ? ColorFilter.mode(color, BlendMode.srcIn)
                : null,
          )
        : const SizedBox();
  }

  static Widget getPngImage(
    String assetName, {
    BoxFit fit = BoxFit.contain,
    double? height,
    double? width,
  }) {
    return assetName.isNotEmpty
        ? Image(
            image: AssetImage('assets/png/$assetName.png'),
            height: height,
            width: width,
            fit: fit,
          )
        : const SizedBox();
  }
}
