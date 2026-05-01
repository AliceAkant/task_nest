import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/infrastructure/routes/app_routes.dart';
import 'package:task_nest/presentation/blocs/events_count/events_count_cubit.dart'
    as e;
import 'package:task_nest/presentation/blocs/members/members_cubit.dart';
import 'package:task_nest/presentation/blocs/schedule/schedule_cubit.dart';
import 'package:task_nest/presentation/enum/app_svg.dart';
import 'package:task_nest/presentation/enum/date_filter_mode.dart';
import 'package:task_nest/presentation/enum/schedule_view_mode.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/extensions/date_time_extension.dart';
import 'package:task_nest/presentation/helpers/app_bar_creator.dart';
import 'package:task_nest/presentation/helpers/bottom_sheet_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/cards/event_card.dart';
import 'package:task_nest/presentation/widgets/states/error_state_view.dart';
import 'package:task_nest/presentation/widgets/states/loading_state_view.dart';
import 'package:task_nest/presentation/widgets/views/calendar_view.dart';
import 'package:task_nest/presentation/widgets/views/filter_bottom_sheet.dart';
import 'package:task_nest/presentation/widgets/views/filters_view.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final double _addButtonSize = AppSizes.size60;
  DateTime _selectedWeekDay = DateTime.now().dateOnly;

  Future _openFilter(BuildContext context) async {
    final membersState = context.read<MembersCubit>().state;

    if (membersState is DataLoaded) {
      final currentState = context.read<ScheduleCubit>().state;
      final isDayMode = currentState.viewMode == ScheduleViewMode.day;

      final result = await BottomSheetHelper.show(
        context,
        content: FilterBottomSheet(
          memberFilterMode: currentState.memberFilterMode,
          members: membersState.members,
          initialMember: currentState.selectedMember,
          initialDate: isDayMode ? currentState.selectedDate : null,
          showDateFilter: isDayMode,
        ),
      );

      if (context.mounted && result is FilterResult) {
        if (result.reset) {
          if (isDayMode) {
            context.read<ScheduleCubit>().resetAllFilters();
          } else {
            context.read<ScheduleCubit>().resetMemberFilter();
          }
        } else {
          context.read<ScheduleCubit>().filterBy(
            memberFilterMode: result.mFilterMode,
            member: result.member,
            date: isDayMode ? result.date : null,
          );
        }
      }
    }
  }

  Future _addEvent(BuildContext context) async {
    final cubit = context.read<ScheduleCubit>();
    DateTime? dateFilter;

    if (cubit.state.viewMode == ScheduleViewMode.week) {
      dateFilter = _selectedWeekDay;
    } else if (cubit.state.viewMode == ScheduleViewMode.month &&
        cubit.state.selectedDate != null) {
      dateFilter = cubit.state.selectedDate;
    } else if (cubit.state.dateFilterMode == DateFilterMode.dateFilter) {
      dateFilter = cubit.state.selectedDate;
    }

    final result = await context.push(AppRoutes.addEvent, extra: dateFilter);

    if (context.mounted && result != null) {
      cubit.updateState();
      context.read<e.EventsCountCubit>().loadData();
    }
  }

  Future _editEvent(BuildContext context, Event event) async {
    final result = await context.push(AppRoutes.editEvent, extra: event);

    if (context.mounted && result != null) {
      context.read<ScheduleCubit>().updateState();
      context.read<e.EventsCountCubit>().loadData();
    }
  }

  void _onViewModeChanged(BuildContext context, ScheduleViewMode mode) {
    if (mode == ScheduleViewMode.week) {
      setState(() => _selectedWeekDay = DateTime.now().dateOnly);
    }
    context.read<ScheduleCubit>().setViewMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: AppBarCreator.generic(
            context,
            titleKey: LocaleKeys.schedule,
          ),
          floatingActionButton: _AddButton(
            size: _addButtonSize,
            isVisible: !state.isLoading && !state.hasError,
            onTap: () => _addEvent(context),
          ),
          body: _body(context, state),
        );
      },
    );
  }

  Widget _body(BuildContext context, ScheduleState state) {
    final isInitialLoading = state.isLoading && state.rawEvents.isEmpty;

    if (isInitialLoading) {
      return const LoadingStateView();
    }

    if (state.error != null) {
      return ErrorStateView(
        message: state.error,
        onUpdateTap: () => context.read<ScheduleCubit>().updateState(),
      );
    }

    return _dataState(context, state);
  }

  Widget _dataState(BuildContext context, ScheduleState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSizes.spacing8),
        _viewModeSwitcher(context, state),
        const SizedBox(height: AppSizes.spacing8),
        FiltersView(
          mFilterMode: state.memberFilterMode,
          memberFilter: state.selectedMember,
          dateFilter: state.viewMode == ScheduleViewMode.day
              ? state.selectedDate
              : null,
          resetMember: () =>
              context.read<ScheduleCubit>().resetMemberFilter(),
          resetDate: () => context.read<ScheduleCubit>().resetDateFilter(),
          openFilters: () => _openFilter(context),
        ),
        const SizedBox(height: AppSizes.spacing8),
        if (state.isLoading)
          const Expanded(child: LoadingStateView())
        else
          Expanded(child: _contentByMode(context, state)),
      ],
    );
  }

  Widget _viewModeSwitcher(BuildContext context, ScheduleState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing12),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<ScheduleViewMode>(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: context.colors.lightPurple40,
          selectedForegroundColor: context.colors.purple,
          foregroundColor: context.colors.labelSecondary,
          side: BorderSide(color: context.colors.lightPurple40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.barRadius),
          ),
        ),
        segments: [
          const ButtonSegment(
            value: ScheduleViewMode.day,
            icon: Icon(Icons.view_day_outlined, size: AppSizes.size20),
          ),
          const ButtonSegment(
            value: ScheduleViewMode.week,
            icon: Icon(Icons.view_week_outlined, size: AppSizes.size20),
          ),
          ButtonSegment(
            value: ScheduleViewMode.month,
            icon: SvgPicture.asset(
              AppSvg.grid.svgPath,
              height: AppSizes.size20,
              width: AppSizes.size20,
              colorFilter: ColorFilter.mode(
                state.viewMode == ScheduleViewMode.month
                    ? context.colors.purple
                    : context.colors.labelSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
        selected: {state.viewMode},
        onSelectionChanged: (modes) =>
            _onViewModeChanged(context, modes.first),
      ),
      ),
    );
  }

  Widget _contentByMode(BuildContext context, ScheduleState state) {
    switch (state.viewMode) {
      case ScheduleViewMode.week:
        return _weekView(context, state);
      case ScheduleViewMode.month:
        return _monthView(context, state);
      case ScheduleViewMode.day:
        return _dayView(context, state);
    }
  }

  // ──────────────────────────────────────────────
  // DAY VIEW
  // ──────────────────────────────────────────────

  Widget _dayView(BuildContext context, ScheduleState state) {
    return _eventsList(context, state.filteredEvents);
  }

  // ──────────────────────────────────────────────
  // WEEK VIEW
  // ──────────────────────────────────────────────

  Widget _weekView(BuildContext context, ScheduleState state) {
    final sortedDays = state.rawEvents.keys.toList()..sort();

    return Column(
      children: [
        _weekDayStrip(context, sortedDays, state),
        const SizedBox(height: AppSizes.spacing8),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: _addButtonSize + AppSizes.spacing8,
            ),
            child: _eventsGroup(
              context,
              events: state.filteredEvents[_selectedWeekDay] ?? [],
              onEdit: (ev) => _editEvent(context, ev),
            ),
          ),
        ),
      ],
    );
  }

  Widget _weekDayStrip(
    BuildContext context,
    List<DateTime> days,
    ScheduleState state,
  ) {
    if (days.isEmpty) return const SizedBox.shrink();
    final locale = context.locale.toString();

    return SizedBox(
      height: AppSizes.size60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing8),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final day = days[i];
          final isSelected = day == _selectedWeekDay;
          final isToday = day == DateTime.now().dateOnly;
          final hasEvents = (state.rawEvents[day]?.isNotEmpty) ?? false;

          return GestureDetector(
            onTap: () => setState(() => _selectedWeekDay = day),
            child: Container(
              width: AppSizes.size48,
              margin: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing4,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.lightPurple40
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.barRadius),
                border: isToday && !isSelected
                    ? Border.all(
                        color: context.colors.purple,
                        width: AppSizes.border2,
                      )
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BaseText(
                    DateFormat.E(locale).format(day).toUpperCase(),
                    localized: false,
                    fontSize: 10,
                    fontWeight: TypographyConst.wSemiBold,
                    color: isSelected
                        ? context.colors.purple
                        : context.colors.labelSecondary,
                  ),
                  const SizedBox(height: AppSizes.spacing2),
                  BaseText(
                    '${day.day}',
                    localized: false,
                    fontSize: TypographyConst.labelMedium,
                    fontWeight: isSelected || isToday
                        ? TypographyConst.wSemiBold
                        : TypographyConst.wRegular,
                    color: isSelected
                        ? context.colors.purple
                        : context.colors.labelPrimary,
                  ),
                  const SizedBox(height: AppSizes.spacing2),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: hasEvents
                          ? context.colors.purple
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────
  // MONTH VIEW
  // ──────────────────────────────────────────────

  Widget _monthView(BuildContext context, ScheduleState state) {
    return BlocBuilder<e.EventsCountCubit, e.EventsCountState>(
      builder: (context, countState) {
        final countMap =
            countState is e.DataLoaded ? countState.countsMap : null;

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: _addButtonSize + AppSizes.spacing8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing12,
                ),
                child: CalendarView(
                  initialDate: state.selectedDate,
                  showFooter: false,
                  dayEventCountMap: countMap,
                  onDateChanged: (date) {
                    if (date != null) {
                      context.read<ScheduleCubit>().loadByDate(date);
                    }
                  },
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.spacing8),
              if (state.selectedDate != null) ...[
                _dayHeader(context, date: state.selectedDate!),
                const SizedBox(height: AppSizes.spacing4),
                _eventsGroup(
                  context,
                  events: state.filteredEvents[state.selectedDate] ?? [],
                  onEdit: (ev) => _editEvent(context, ev),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.spacing24),
                  child: BaseText(
                    LocaleKeys.choose_date,
                    color: context.colors.labelSecondary,
                    align: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // SHARED
  // ──────────────────────────────────────────────

  Widget _eventsList(
    BuildContext context,
    Map<DateTime, List<Event>> eventsGroups,
  ) {
    final entries = eventsGroups.entries.toList();
    return ListView.builder(
      itemCount: entries.length,
      padding: EdgeInsets.only(
        top: AppSizes.spacing4,
        bottom: _addButtonSize + AppSizes.spacing8,
      ),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dayHeader(context, date: entry.key),
            const SizedBox(height: AppSizes.spacing4),
            _eventsGroup(
              context,
              events: entry.value,
              onEdit: (ev) => _editEvent(context, ev),
            ),
          ],
        );
      },
    );
  }

  Widget _dayHeader(BuildContext context, {required DateTime date}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing12),
      child: BaseText(
        _formatDate(context, date),
        fontWeight: TypographyConst.wSemiBold,
        fontSize: TypographyConst.labelLarge,
        localized: false,
        align: TextAlign.center,
      ),
    );
  }

  Widget _eventsGroup(
    BuildContext context, {
    required List<Event> events,
    required Function(Event) onEdit,
  }) {
    if (events.isEmpty) {
      return _emptyDay(context);
    }

    final localeKey = context.locale.toString();
    events.sortBy((ev) => ev.dateTime);

    final grouped = groupBy(events, (ev) => ev.dateTime.toTimeFormat(localeKey));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacing4),
              child: BaseText.secondary(
                entry.key,
                align: TextAlign.center,
                fontSize: TypographyConst.labelMedium,
                localized: false,
              ),
            ),
            ...entry.value.map(
              (ev) => Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.spacing12,
                  0,
                  AppSizes.spacing12,
                  AppSizes.spacing16,
                ),
                child: EventCard(
                  event: ev,
                  isPassed: ev.dateTime.isBefore(DateTime.now()),
                  onTap: (_) => onEdit(ev),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _emptyDay(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.spacing4,
        bottom: AppSizes.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSizes.spacing24),
          BaseText(
            LocaleKeys.empty_day_events_title,
            fontWeight: TypographyConst.wSemiBold,
            align: TextAlign.center,
            maxLines: 2,
            fontSize: TypographyConst.labelStandart,
          ),
          const SizedBox(height: AppSizes.spacing2),
          BaseText(
            LocaleKeys.empty_day_events_message,
            fontSize: TypographyConst.labelMedium,
            maxLines: 2,
            align: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacing24),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = context.locale.toString();
    final today = DateTime.now().dateOnly;
    final dateStr = date.dMMMM(locale);

    if (date.dateOnly == today) {
      return "${tr(LocaleKeys.today)} - $dateStr";
    } else if (date.dateOnly == today.add(const Duration(days: 1))) {
      return "${tr(LocaleKeys.tomorrow)} - $dateStr";
    }

    return dateStr;
  }
}

class _AddButton extends StatelessWidget {
  final double size;
  final bool isVisible;
  final Function() onTap;

  const _AddButton({
    required this.size,
    required this.isVisible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox();
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onTap: () => onTap.call(),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colors.purple,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(120),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '+',
            style: TextStyle(fontSize: 30, color: context.colors.background),
          ),
        ),
      ),
    );
  }
}
