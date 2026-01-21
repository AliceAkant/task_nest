import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:task_nest/presentation/enum/app_svg.dart';

class SvgCacheManager {
  static Future precacheAppSvgList() async {
    for (final asset in AppSvg.values) {
      final loader = SvgAssetLoader(asset.svgPath);
      svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    }
  }
}

class AssetsHelper {
  static final Map<AppSvg, SvgAssetLoader> _loaderCache = {};

  static SvgAssetLoader _getSharedLoader(AppSvg asset) {
    return _loaderCache.putIfAbsent(asset, () => SvgAssetLoader(asset.svgPath));
  }

  static Widget getSvgImage(
    AppSvg asset, {
    double? height,
    double? width,
    Color? color,
  }) {
    return SvgPicture(
      _getSharedLoader(asset),
      height: height,
      width: width,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
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
