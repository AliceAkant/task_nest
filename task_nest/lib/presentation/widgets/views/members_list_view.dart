import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/infrastructure/routes/app_routes.dart';
import 'package:task_nest/presentation/blocs/members/members_cubit.dart';
import 'package:task_nest/presentation/enum/button_kind.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/assets_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/bordered_icon_button.dart';
import 'package:task_nest/presentation/widgets/cards/avatar_card.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';

class MembersListView extends StatelessWidget {
  final Widget? separator;
  const MembersListView({this.separator, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _addMemberButton(context),
        separator ?? const SizedBox(),
        _members(),
      ],
    );
  }

  Widget _members() {
    return BlocBuilder<MembersCubit, MembersState>(
      builder: (context, state) {
        return state is Loading
            ? _loadingState(context)
            : state is DataLoaded
            ? _membersState(context, state.members)
            : state is LoadError
            ? _errorState(context)
            : Center(child: Text('Ничего нету'));
      },
    );
  }

  ///
  /// MEMBERS STATES
  ///

  Widget _loadingState(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSizes.spacing12),
        height: AppSizes.size32,
        width: AppSizes.size32,
        child: CircularProgressIndicator(color: context.colors.purple),
      ),
    );
  }

  Widget _membersState(BuildContext context, List<Member> members) {
    return members.isEmpty
        ? _emptyMembers(context)
        : Column(
            children: List.generate(
              members.length,
              (index) => _memberItem(
                context,
                member: members[index],
                isLast: index == members.length - 1,
                addSeparator: index != 0,
              ),
            ),
          );
  }

  Widget _errorState(BuildContext context) {
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

  Widget _emptyMembers(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.all(AppSizes.spacing12),
      child: BaseText.secondary(
        LocaleKeys.no_members_added,
        fontWeight: TypographyConst.wSemiBold,
      ),
    );
  }

  ///
  /// WIDGETS
  ///

  Widget _addMemberButton(BuildContext context) {
    return TappableBox(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppSizes.barRadius),
        topRight: Radius.circular(AppSizes.barRadius),
      ),
      onTap: () async {
        var result = await context.push(AppRoutes.addMember);

        if (context.mounted && result != null) {
          context.read<MembersCubit>().loadData();
        }
      },
      child: Padding(
        padding: const EdgeInsetsGeometry.all(AppSizes.spacing12),
        child: Row(
          children: [
            AssetsHelper.getSvgImage(
              'add_person',
              height: AppSizes.size24,
              color: context.colors.labelPrimary,
            ),
            const SizedBox(width: AppSizes.spacing8),
            BaseText(LocaleKeys.add_member),
          ],
        ),
      ),
    );
  }

  Widget _memberItem(
    BuildContext context, {
    required Member member,
    bool isLast = false,
    bool addSeparator = false,
  }) {
    return TappableBox(
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(AppSizes.barRadius),
              bottomRight: Radius.circular(AppSizes.barRadius),
            )
          : null,
      onTap: () async {
        var result = await context.push(AppRoutes.editMember, extra: member);

        if (context.mounted && result != null) {
          context.read<MembersCubit>().loadData();
        }
      },
      child: Column(
        children: [
          addSeparator && separator != null ? separator! : const SizedBox(),
          Padding(
            padding: const EdgeInsetsGeometry.symmetric(
              horizontal: AppSizes.spacing12,
              vertical: AppSizes.spacing8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AvatarCard(
                  theme: member.theme,
                  avatar: member.avatar,
                  size: AvatarSize.small,
                ),

                const SizedBox(width: AppSizes.spacing8),
                Expanded(child: BaseText(member.name, localized: false)),
                Icon(
                  Icons.chevron_right,
                  color: context.colors.labelSecondary,
                  size: AppSizes.size28,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
