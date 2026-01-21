import 'package:flutter/material.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/domain/enums/member_theme.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/assets_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';

enum AvatarSize { standart, small, huge }

class AvatarCard extends StatelessWidget {
  final MemberTheme? theme;
  final bool disabled;
  final Avatar avatar;
  final AvatarSize size;

  const AvatarCard({
    super.key,
    required this.theme,
    required this.avatar,
    this.disabled = false,
    this.size = AvatarSize.standart,
  });

  @override
  Widget build(BuildContext context) {
    final height = _getCardSize();

    return _avatar(context, size: height);
  }

  double _getCardSize() {
    switch (size) {
      case AvatarSize.standart:
        return AppSizes.size48;
      case AvatarSize.small:
        return AppSizes.size36;
      case AvatarSize.huge:
        return AppSizes.size60;
    }
  }

  Widget _avatar(BuildContext context, {required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: Container(
              padding: const EdgeInsets.all(AppSizes.spacing4),
              decoration: BoxDecoration(
                color: disabled
                    ? context.colors.disable
                    : theme?.color ?? context.colors.lightPurple40,
                shape: BoxShape.circle,
                border: Border.all(
                  color: disabled
                      ? context.colors.borderDisabled
                      : theme?.borderColor ?? context.colors.purple,
                  width: AppSizes.border2,
                ),
              ),
              child: AssetsHelper.getSvgImage(
                avatar.asset,
                height: AppSizes.size24,
              ),
            ),
          ),
          if (disabled)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: disabled
                      ? context.colors.lightGrey150
                      : theme?.color ?? context.colors.lightPurple40,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
