import 'package:flutter/material.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/presentation/enum/member_filter_mode.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/core/extensions/date_time_extension.dart';
import 'package:task_nest/presentation/extensions/string_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';

class FiltersView extends StatelessWidget {
  final MemberFilterMode mFilterMode;
  final Member? memberFilter;
  final DateTime? dateFilter;
  final Function()? resetMember;
  final Function()? resetDate;
  final Function()? openFilters;

  const FiltersView({
    required this.mFilterMode,
    this.memberFilter,
    this.dateFilter,
    this.resetMember,
    this.resetDate,
    this.openFilters,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = memberFilter != null || dateFilter != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing12),
        child: Row(
          children: [
            _filterButton(context, hasFilters, () => openFilters?.call()),

            const SizedBox(width: AppSizes.spacing12),

            if (mFilterMode != MemberFilterMode.member)
              _filterItem(
                context,
                title: mFilterMode == MemberFilterMode.all
                    ? LocaleKeys.all_members
                    : LocaleKeys.only_mine,
                resetAvailable: false,
              ),

            if (memberFilter != null)
              _filterItem(
                context,
                title: memberFilter!.name,
                onTap: () => resetMember?.call(),
              ),
            if (dateFilter != null)
              _filterItem(
                context,
                title: dateFilter!.dateOnly.dateSimpleFormat,
                onTap: () => resetDate?.call(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(
    BuildContext context,
    bool hasFilters,
    Function() onTap,
  ) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(AppSizes.barRadius),
            ),
            border: Border.all(
              width: AppSizes.border2,
              color: hasFilters
                  ? context.colors.borderFocused
                  : context.colors.borderSecondary,
            ),
          ),
          child: InkWell(
            splashColor: context.colors.defaultSplash,
            highlightColor: context.colors.defaultSplash,
            borderRadius: BorderRadius.circular(AppSizes.barRadius),
            onTap: () => onTap(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.spacing12,
                vertical: AppSizes.spacing8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    color: hasFilters
                        ? context.colors.purple
                        : context.colors.labelPrimary,
                    size: AppSizes.size24,
                  ),
                  const SizedBox(width: AppSizes.spacing2),
                  BaseText(
                    LocaleKeys.filter,
                    fontWeight: TypographyConst.wSemiBold,
                    fontSize: TypographyConst.labelMedium,
                    color: hasFilters
                        ? context.colors.purple
                        : context.colors.labelPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasFilters)
          Container(
            height: AppSizes.size12,
            width: AppSizes.size12,
            decoration: BoxDecoration(
              color: context.colors.purple,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _filterItem(
    BuildContext context, {
    required String title,
    bool resetAvailable = true,
    Function()? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: AppSizes.spacing8),
      child: TappableBox(
        onTap: () => onTap?.call(),
        backgroundColor: context.colors.lightPurple40,
        splashColor: context.colors.defaultSplash,
        borderRadius: BorderRadius.circular(AppSizes.barRadius),
        border: Border.all(
          width: AppSizes.border1,
          color: context.colors.borderFocused,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.spacing8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: resetAvailable ? AppSizes.spacing12 : AppSizes.spacing8,
              ),
              BaseText(
                title.truncate(),
                fontWeight: TypographyConst.wSemiBold,
                fontSize: TypographyConst.labelMedium,
                color: context.colors.purple,
              ),
              if (resetAvailable)
                Padding(
                  padding: const EdgeInsets.only(left: AppSizes.spacing2),
                  child: Icon(
                    Icons.close,
                    size: AppSizes.size20,
                    color: context.colors.purple,
                  ),
                ),
              const SizedBox(width: AppSizes.spacing8),
            ],
          ),
        ),
      ),
    );
  }
}
