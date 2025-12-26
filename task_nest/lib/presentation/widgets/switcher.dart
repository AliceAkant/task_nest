import 'package:flutter/material.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';

class Switcher extends StatefulWidget {
  final bool initialValue;
  final double height;
  final double width;
  final ValueChanged<bool>? onChanged;

  const Switcher({
    super.key,
    required this.initialValue,
    this.height = AppSizes.size30,
    this.width = AppSizes.size50,
    this.onChanged,
  });

  @override
  State<Switcher> createState() => _SwitcherState();
}

class _SwitcherState extends State<Switcher> {
  final double padding = 2;
  late final double circleSize;
  late bool isToggled;

  @override
  void initState() {
    super.initState();
    isToggled = widget.initialValue;
    circleSize = widget.height - padding * 2;
  }

  void _toggle() {
    setState(() {
      isToggled = !isToggled;
    });
    widget.onChanged?.call(isToggled);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        height: widget.height,
        width: widget.width,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: isToggled ? context.colors.purple : context.colors.lightGrey,
          borderRadius: BorderRadius.circular(AppSizes.barRadius),
        ),
        padding: EdgeInsets.all(padding),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
          transform: Matrix4.translationValues(
            isToggled ? 18.0 : 0.0,
            0.0,
            0.0,
          ),
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
