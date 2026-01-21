import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/infrastructure/routes/app_routes.dart';
import 'package:task_nest/presentation/blocs/events_count/events_count_cubit.dart'
    as e;
import 'package:task_nest/presentation/blocs/members/members_cubit.dart';
import 'package:task_nest/presentation/blocs/schedule/schedule_cubit.dart';
import 'package:task_nest/presentation/enum/date_filter_mode.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/extensions/date_time_extension.dart';
import 'package:task_nest/presentation/helpers/bottom_sheet_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/helpers/app_bar_creator.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/cards/event_card.dart';
import 'package:task_nest/presentation/widgets/states/error_state_view.dart';
import 'package:task_nest/presentation/widgets/states/loading_state_view.dart';
import 'package:task_nest/presentation/widgets/views/filter_bottom_sheet.dart';
import 'package:task_nest/presentation/widgets/views/filters_view.dart';

class ScheduleScreen extends StatelessWidget {
  final double _addButtonSize = AppSizes.size60;

  const ScheduleScreen({super.key});

  Future _openFilter(BuildContext context) async {
    final membersState = context.read<MembersCubit>().state;

    if (membersState is DataLoaded) {
      final currentState = context.read<ScheduleCubit>().state;

      final result = await BottomSheetHelper.show(
        context,
        content: FilterBottomSheet(
          memberFilterMode: currentState.memberFilterMode,
          members: membersState.members,
          initialMember: currentState.selectedMember,
          initialDate: currentState.selectedDate,
        ),
      );

      if (context.mounted && result is FilterResult) {
        if (result.reset) {
          context.read<ScheduleCubit>().resetAllFilters();
        } else {
          context.read<ScheduleCubit>().filterBy(
            memberFilterMode: result.mFilterMode,
            member: result.member,
            date: result.date,
          );
        }
      }
    }
  }

  Future _resetMemberFilter(BuildContext context) async {
    context.read<ScheduleCubit>().resetMemberFilter();
  }

  Future _resetDateFilter(BuildContext context) async {
    context.read<ScheduleCubit>().resetDateFilter();
  }

  Future _addEvent(BuildContext context) async {
    final cubit = context.read<ScheduleCubit>();
    final dateFilter = cubit.state.dateFilterMode == DateFilterMode.dateFilter
        ? cubit.state.selectedDate
        : null;

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: AppBarCreator.generic(context, titleKey: LocaleKeys.schedule),
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
    if (state.isLoading) {
      return LoadingStateView();
    } else if (state.error != null) {
      return ErrorStateView(
        message: state.error,
        onUpdateTap: () => context.read<ScheduleCubit>().updateState(),
      );
    } else {
      return _dataState(context, state);
    }
  }

  Widget _dataState(BuildContext context, ScheduleState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSizes.spacing8),

        // FILTERS
        FiltersView(
          mFilterMode: state.memberFilterMode,
          memberFilter: state.selectedMember,
          dateFilter: state.selectedDate,
          resetMember: () => _resetMemberFilter(context),
          resetDate: () => _resetDateFilter(context),
          openFilters: () => _openFilter(context),
        ),

        const SizedBox(height: AppSizes.spacing8),

        // EVENTS
        Expanded(child: _eventsList(context, state.filteredEvents)),
      ],
    );
  }

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
              onEdit: (e) => _editEvent(context, e),
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
    } else {
      final localeKey = context.locale.toString();
      events.sortBy((e) => e.dateTime);

      final grouped = groupBy(
        events,
        (e) => e.dateTime.toTimeFormat(localeKey),
      );

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
                (e) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.spacing12,
                    0,
                    AppSizes.spacing12,
                    AppSizes.spacing16,
                  ),
                  child: EventCard(
                    event: e,
                    isPassed: e.dateTime.isBefore(DateTime.now()),
                    onTap: (_) => onEdit(e),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      );
    }
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
    } else if (date.dateOnly == today.add(Duration(days: 1))) {
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
    if (!isVisible) return SizedBox();
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
