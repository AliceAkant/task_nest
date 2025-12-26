import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/presentation/blocs/members/members_cubit.dart';
import 'package:task_nest/presentation/enum/button_kind.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/bordered_icon_button.dart';

class LoadMembersErrorStateView extends StatelessWidget {
  const LoadMembersErrorStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.spacing12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BaseText(
                  LocaleKeys.load_members_failed,
                  height: 1.2,
                  fontSize: TypographyConst.labelMedium,
                  align: TextAlign.center,
                  color: context.colors.error,
                  maxLines: 5,
                ),
                BaseText(
                  LocaleKeys.general_load_failed_message,
                  height: 1.2,
                  fontSize: TypographyConst.labelMedium,
                  align: TextAlign.center,
                  color: context.colors.error,
                  maxLines: 5,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacing4),
          BorderedIconButton(
            iconSource: 'refresh',
            kind: ButtonKind.error,
            isEnabled: true,
            onTap: () => context.read<MembersCubit>().loadData(),
          ),
        ],
      ),
    );
  }
}
