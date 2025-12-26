import 'package:flutter/material.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';

class BottomSheetHelper {
  static Future show(
    BuildContext context, {
    required Widget content,
    bool closeByOverlayTap = true,
    double? fixedHeight,
  }) {
    return _showDialog(
      context,
      content: content,
      fixedHeight: fixedHeight,
      closeByOverlayTap: closeByOverlayTap,
    );
  }

  static Future _showDialog(
    BuildContext context, {
    required Widget content,
    double? fixedHeight,
    bool closeByOverlayTap = true,
  }) {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: closeByOverlayTap,
      backgroundColor: context.colors.background,
      isDismissible: closeByOverlayTap,
      enableDrag: closeByOverlayTap,
      barrierColor: Colors.black.withAlpha(140),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.barRadius),
        ),
      ),
      builder: (ctx) {
        Widget child = Padding(
          padding: EdgeInsets.only(
            bottom: ctx.bottomInset + AppSizes.bottomSheetPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentGeometry.topCenter,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: AppSizes.spacing12),
                  color: context.colors.lightGrey150,
                  height: AppSizes.size4,
                  width: AppSizes.size48,
                ),
              ),
              content,
            ],
          ),
        );

        if (fixedHeight != null) {
          child = SizedBox(
            height: fixedHeight,
            child: SingleChildScrollView(child: child),
          );
        }

        return child;
      },
    );
  }
}
