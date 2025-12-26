import 'package:flutter/material.dart';

class TabItem {
  final String screenName;
  final String titleKey;
  final String iconSource;
  final Widget screenView;

  TabItem(this.screenName, this.titleKey, this.iconSource, this.screenView);
}
