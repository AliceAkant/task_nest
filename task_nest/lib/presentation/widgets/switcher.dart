import 'package:flutter/material.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';

class Switcher extends StatelessWidget {
  final bool value;
  final double height;
  final double width;
  final ValueChanged<bool>? onChanged;

  const Switcher({
    super.key,
    required this.value,
    this.height = AppSizes.size30,
    this.width = AppSizes.size50,
    this.onChanged,
  });

  static const double _padding = 2;

  @override
  Widget build(BuildContext context) {
    final circleSize = height - _padding * 2;
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? context.colors.purple : context.colors.lightGrey,
          borderRadius: BorderRadius.circular(AppSizes.barRadius),
        ),
        padding: const EdgeInsets.all(_padding),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
          transform: Matrix4.translationValues(value ? 18.0 : 0.0, 0.0, 0.0),
          child: Container(
            height: circleSize,
            width: circleSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(circleSize / 2),
            ),
          ),
        ),
      ),
    );
  }
}
