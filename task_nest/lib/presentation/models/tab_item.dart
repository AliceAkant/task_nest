import 'package:flutter/material.dart';
import 'package:task_nest/presentation/enum/app_svg.dart';

class TabItem {
  final String screenName;
  final String titleKey;
  final AppSvg iconSource;
  final Widget screenView;

  TabItem(this.screenName, this.titleKey, this.iconSource, this.screenView);
}
