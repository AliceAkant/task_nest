import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/domain/enums/member_theme.dart';
import 'package:task_nest/presentation/blocs/events_count/events_count_cubit.dart';
import 'package:task_nest/presentation/enum/member_filter_mode.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/extensions/date_time_extension.dart';
import 'package:task_nest/presentation/extensions/string_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/bordered_button.dart';
import 'package:task_nest/presentation/widgets/cards/avatar_card.dart';
import 'package:task_nest/presentation/widgets/date_picker.dart';
import 'package:task_nest/presentation/widgets/rounded_button.dart';
import 'package:task_nest/presentation/widgets/switcher.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';
import 'package:task_nest/presentation/widgets/title_block.dart';

class FilterResult {
  final bool reset;
  final MemberFilterMode mFilterMode;
  final Member? member;
  final DateTime? date;

  FilterResult({
    required this.reset,
    required this.mFilterMode,
    required this.member,
    required this.date,
  });
}

class FilterBottomSheet extends StatefulWidget {
  final MemberFilterMode memberFilterMode;
  final Member? initialMember;
  final DateTime? initialDate;
  final List<Member> members;

  const FilterBottomSheet({
    required this.memberFilterMode,
    required this.members,
    required this.initialDate,
    this.initialMember,
    super.key,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  Member? selectedMember;
  DateTime? selectedDate;
  late MemberFilterMode mFilterMode;

  @override
  void initState() {
    super.initState();
    selectedMember = widget.initialMember;
    selectedDate = widget.initialDate;
    mFilterMode = widget.memberFilterMode;
  }

  // ACTIONS

  void _onApplyTap(BuildContext context) {
    final result = FilterResult(
      reset: false,
      member: selectedMember,
      mFilterMode: mFilterMode,
      date: selectedDate?.dateOnly,
    );

    Navigator.of(context).pop(result);
  }

  void _onResetTap(BuildContext context) {
    final result = FilterResult(
      reset: true,
      member: null,
      mFilterMode: widget.memberFilterMode,
      date: null,
    );

    Navigator.of(context).pop(result);
  }

  // LOCAL

  Future _chooseDate(DateTime? date) async {
    setState(() {
      selectedDate = selectedDate?.dateOnly == date?.dateOnly
          ? null
          : date?.dateOnly;
    });
  }

  void _toggleOnlyMine(bool isMine) {
    setState(() {
      selectedMember = null;
      mFilterMode = isMine ? MemberFilterMode.mine : MemberFilterMode.all;
    });
  }

  void _selectMember(Member member) {
    setState(() {
      selectedMember = selectedMember == member ? null : member;
      mFilterMode = MemberFilterMode.member;
    });
  }

  void _resetMember() {
    setState(() {
      selectedMember = null;
      mFilterMode = MemberFilterMode.all;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER
          Center(
            child: BaseText(
              LocaleKeys.schedule_filters,
              fontWeight: TypographyConst.wBold,
              fontSize: TypographyConst.labelLarge,
            ),
          ),
          const SizedBox(height: AppSizes.spacing12),

          _onlyMySwitcher(context),

          const SizedBox(height: AppSizes.spacing12),

          // MEMBERS
          _membersView(context),

          const SizedBox(height: AppSizes.spacing12),

          // DATE
          BaseText.secondary(
            LocaleKeys.choose_date,
            fontWeight: TypographyConst.wSemiBold,
          ),
          const SizedBox(height: AppSizes.spacing8),
          BlocBuilder<EventsCountCubit, EventsCountState>(
            builder: (context, state) {
              final eventsCountMap = state is DataLoaded
                  ? state.countsMap
                  : null;
              // if (state is LoadError) {
              //   context.read<EventsCountCubit>().loadData();
              // }

              return DatePicker(
                key: ValueKey('date_filter_picker'),
                initialDate: selectedDate,
                eventsCountMap: eventsCountMap,
                onDateChanged: (date) => _chooseDate(date),
              );
            },
          ),
          const SizedBox(height: AppSizes.spacing24),

          // BUTTONS
          RoundedButton(
            textKey: LocaleKeys.apply,
            isEnabled:
                selectedMember != widget.initialMember ||
                selectedDate != widget.initialDate ||
                mFilterMode != widget.memberFilterMode,
            onTap: () => _onApplyTap(context),
          ),
          const SizedBox(height: AppSizes.spacing8),
          BorderedButton(
            textKey: LocaleKeys.reset,
            onTap: () => _onResetTap(context),
          ),
        ],
      ),
    );
  }

  Widget _membersView(BuildContext context) {
    final disabled = mFilterMode == MemberFilterMode.mine;

    return AbsorbPointer(
      absorbing: disabled,
      child: TitleBlock(
        outlined: true,
        titleKey: LocaleKeys.choose_member,
        child: _membersFilter(disabled: disabled),
      ),
    );
  }

  Widget _membersFilter({bool disabled = false}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: AppSizes.memberFilterMaxHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing4),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: AppSizes.spacing8,
                  runSpacing: AppSizes.spacing4,
                  children: [
                    _allMembersCard(context, disabled),
                    ...widget.members.map((member) {
                      final isSelected = selectedMember?.id == member.id;

                      return _memberCard(
                        context,
                        member.name,
                        member.theme,
                        member.avatar,
                        isSelected,
                        disabled,
                        () => _selectMember(member),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _onlyMySwitcher(BuildContext context) {
    final isSelected = mFilterMode == MemberFilterMode.mine;
    return TappableBox(
      splashColor: Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(AppSizes.barRadius)),
      border: Border.all(
        width: AppSizes.border1,
        color: isSelected
            ? context.colors.purple
            : context.colors.borderSecondary,
      ),
      backgroundColor: context.colors.lightPurple40,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing12),
        child: Row(
          children: [
            Expanded(
              child: BaseText(
                LocaleKeys.show_only_mine,
                fontWeight: TypographyConst.wSemiBold,
                color: isSelected
                    ? context.colors.purple
                    : context.colors.labelSecondary,
              ),
            ),
            Switcher(initialValue: isSelected, onChanged: _toggleOnlyMine),
          ],
        ),
      ),
    );
  }

  Widget _allMembersCard(BuildContext context, bool disabled) {
    return _selectableView(
      context,
      isDisabled: disabled,
      isSelected: selectedMember == null,
      onTap: _resetMember,
      child: Container(
        padding: const EdgeInsets.only(left: AppSizes.spacing4),
        height: AppSizes.size36,
        child: Align(
          alignment: Alignment.center,
          child: BaseText(
            LocaleKeys.all_members,
            fontWeight: TypographyConst.wSemiBold,
            fontSize: TypographyConst.labelMedium,
            color: disabled
                ? context.colors.labelDisable
                : context.colors.labelPrimary,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _memberCard(
    BuildContext context,
    String title,
    MemberTheme theme,
    Avatar avatar,
    bool isSelected,
    bool disabled,
    Function() onTap,
  ) {
    return _selectableView(
      context,
      isDisabled: disabled,
      isSelected: isSelected,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AvatarCard(
            theme: theme,
            avatar: avatar,
            size: AvatarSize.small,
            disabled: disabled,
          ),
          const SizedBox(width: AppSizes.spacing8),
          BaseText(
            title.truncate(),
            fontWeight: TypographyConst.wSemiBold,
            fontSize: TypographyConst.labelMedium,
            color: disabled
                ? context.colors.labelDisable
                : context.colors.labelPrimary,
            overflow: TextOverflow.ellipsis,
            localized: false,
          ),
        ],
      ),
    );
  }

  Widget _selectableView(
    BuildContext context, {
    required bool isSelected,
    required Function() onTap,
    required Widget child,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spacing4,
          AppSizes.spacing4,
          AppSizes.spacing8,
          AppSizes.spacing4,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(AppSizes.mediumRadius),
          ),
          border: Border.all(
            width: AppSizes.border2,
            color: isDisabled
                ? context.colors.borderDisabled
                : isSelected
                ? context.colors.borderFocused
                : context.colors.borderSecondary,
          ),
          color: isDisabled
              ? context.colors.buttonDisabled
              : isSelected
              ? context.colors.lightPurple40
              : context.colors.background,
        ),
        child: IntrinsicWidth(child: child),
      ),
    );
  }
}
