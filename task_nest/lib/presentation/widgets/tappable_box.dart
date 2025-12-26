import 'package:flutter/material.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';

class TappableBox extends StatelessWidget {
  final BorderRadius? borderRadius;
  final Color? splashColor;
  final VoidCallback? onTap;
  final Widget child;
  final BoxBorder? border;
  final Color? backgroundColor;

  const TappableBox({
    super.key,
    required this.child,
    this.splashColor,
    this.borderRadius,
    this.onTap,
    this.border,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.zero,
        border: border,
      ),
      child: Material(
        color: backgroundColor ?? context.colors.background,
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: InkWell(
          borderRadius: borderRadius ?? BorderRadius.zero,
          splashColor: onTap == null
              ? Colors.transparent
              : splashColor ?? context.colors.defaultSplash,
          highlightColor: onTap == null
              ? Colors.transparent
              : splashColor ?? context.colors.defaultSplash,
          onTap: () => onTap?.call(),
          child: child,
        ),
      ),
    );
  }
}
