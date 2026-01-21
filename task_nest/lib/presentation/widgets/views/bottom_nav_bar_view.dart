import 'package:flutter/material.dart';
import 'package:task_nest/presentation/enum/app_svg.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/assets_helper.dart';
import 'package:task_nest/presentation/models/tab_item.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/gradient_ripple.dart';

class BottomNavBarView extends StatelessWidget {
  static const double _barHeight = AppSizes.size60;

  final List<TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBarView({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        final bottomInset = context.bottomInset;
        final barViewHeight = _barHeight + bottomInset + AppSizes.bottomPadding;
        final tabWidth = screenWidth / tabs.length;

        return SizedBox(
          width: double.infinity,
          height: barViewHeight,
          child: _tabsView(context, height: barViewHeight, tabWidth: tabWidth),
        );
      },
    );
  }

  Widget _tabsView(
    BuildContext context, {
    required double height,
    required double tabWidth,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.barRadius),
          topRight: Radius.circular(AppSizes.barRadius),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 20),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          tabs.length,
          (index) => _tabView(
            context,
            index,
            currentIndex == index,
            tabWidth,
            tabs[index].titleKey,
            tabs[index].iconSource,
          ),
        ),
      ),
    );
  }

  Widget _tabView(
    BuildContext context,
    int index,
    bool isSelected,
    double width,
    String titleKey,
    AppSvg icon,
  ) {
    return GradientRipple(
      color: context.colors.purple,
      onTap: () => onTap.call(index),
      child: Container(
        width: width,
        height: _barHeight,
        alignment: Alignment.center,
        color: Colors.transparent,
        margin: const EdgeInsets.only(top: AppSizes.spacing8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.lightPurple40
                : Colors.transparent,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppSizes.cardRadius),
            ),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AssetsHelper.getSvgImage(
                icon,
                width: AppSizes.size24,
                color: isSelected
                    ? context.colors.purple
                    : context.colors.labelSecondary,
              ),
              BaseText(
                titleKey,
                fontWeight: TypographyConst.wSemiBold,
                fontSize: TypographyConst.labelSmall,
                color: isSelected
                    ? context.colors.purple
                    : context.colors.labelSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
