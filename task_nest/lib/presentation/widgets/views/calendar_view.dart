import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/extensions/string_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';

typedef SubmitCallback = void Function(DateTime?);
typedef DateChangedCallback = void Function(DateTime?);

class CalendarView extends StatefulWidget {
  final DateTime? initialDate;
  late final DateTime firstDate;
  late final DateTime lastDate;
  final bool resetAvailable;
  final SubmitCallback? onSubmit;
  final VoidCallback? onCancel;
  final VoidCallback? onReset;
  final DateChangedCallback? onDateChanged;

  CalendarView({
    super.key,
    this.initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    this.resetAvailable = true,
    this.onSubmit,
    this.onCancel,
    this.onReset,
    this.onDateChanged,
  }) : firstDate = firstDate ?? DateTime(1900),
       lastDate = lastDate ?? DateTime(2100);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _displayedMonth;
  DateTime? _selectedDate;
  List<String>? _weekDays;

  @override
  void initState() {
    super.initState();

    final seed = widget.initialDate ?? DateTime.now();
    _displayedMonth = DateTime(seed.year, seed.month);
    _selectedDate = widget.initialDate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _weekDays = _getWeekdaysForLocale(context.locale.toString());
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  List<String> _getWeekdaysForLocale(String locale) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - DateTime.monday));

    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return DateFormat.E(locale).format(day).firstCharUppercase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekDays =
        _weekDays ?? _getWeekdaysForLocale(context.locale.toString());

    final daysInMonth = DateUtils.getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );

    final firstWeekday = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    ).weekday;

    final monthName = DateFormat.yMMMM(
      context.locale.toString(),
    ).format(_displayedMonth).firstCharUppercase();

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spacing12,
        horizontal: AppSizes.spacing12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CalendarHeader(
            monthName: monthName,
            onPrev: _prevMonth,
            onNext: _nextMonth,
          ),
          const SizedBox(height: AppSizes.spacing8),
          _WeekDaysRow(weekDays: weekDays),
          const SizedBox(height: AppSizes.spacing4),
          _DaysGrid(
            displayedMonth: _displayedMonth,
            daysInMonth: daysInMonth,
            firstWeekday: firstWeekday,
            selectedDate: _selectedDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            onDateTap: (date) {
              setState(() => _selectedDate = date);
              widget.onDateChanged?.call(date);
            },
          ),
          _CalendarFooter(
            resetAvailable: widget.resetAvailable,
            onCancel: widget.onCancel,
            onReset: widget.onReset,
            onSubmit: () => widget.onSubmit?.call(_selectedDate),
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final String monthName;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _CalendarHeader({
    required this.monthName,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrev,
          iconSize: AppSizes.size32,
          icon: const Icon(Icons.chevron_left),
        ),
        BaseText(monthName, localized: false),
        IconButton(
          onPressed: onNext,
          iconSize: AppSizes.size32,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _WeekDaysRow extends StatelessWidget {
  final List<String> weekDays;

  const _WeekDaysRow({required this.weekDays});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays
          .map(
            (dayName) => Expanded(
              child: Center(
                child: BaseText(
                  dayName,
                  fontWeight: TypographyConst.wSemiBold,
                  fontSize: TypographyConst.labelMedium,
                  localized: false,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DaysGrid extends StatelessWidget {
  final DateTime displayedMonth;
  final int daysInMonth;
  final int firstWeekday;
  final DateTime? selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateTap;

  const _DaysGrid({
    required this.displayedMonth,
    required this.daysInMonth,
    required this.firstWeekday,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: AppSizes.spacing2,
        crossAxisSpacing: AppSizes.spacing2,
      ),
      itemCount: daysInMonth + (firstWeekday - 1),
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1) return const SizedBox.shrink();

        final day = index - (firstWeekday - 2);
        final date = DateTime(displayedMonth.year, displayedMonth.month, day);

        final isSelected =
            selectedDate != null &&
            selectedDate!.year == date.year &&
            selectedDate!.month == date.month &&
            selectedDate!.day == date.day;

        final now = DateTime.now();
        final isToday =
            now.year == date.year &&
            now.month == date.month &&
            now.day == date.day;

        final isDisabled = date.isBefore(firstDate) || date.isAfter(lastDate);

        return GestureDetector(
          onTap: () {
            if (!isDisabled) onDateTap(date);
          },
          child: DayItem(
            key: ValueKey(date),
            date: date,
            isSelected: isSelected,
            isToday: isToday,
            isDisabled: isDisabled,
          ),
        );
      },
    );
  }
}

class _CalendarFooter extends StatelessWidget {
  final bool resetAvailable;
  final VoidCallback? onCancel;
  final VoidCallback? onReset;
  final VoidCallback? onSubmit;

  const _CalendarFooter({
    required this.resetAvailable,
    this.onCancel,
    this.onReset,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _button(context, LocaleKeys.cancel, onCancel),
        const SizedBox(width: AppSizes.spacing2),
        if (resetAvailable)
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.spacing2),
            child: _button(context, LocaleKeys.reset, onReset),
          ),
        _button(context, LocaleKeys.ok, onSubmit),
      ],
    );
  }

  Widget _button(BuildContext context, String textKey, VoidCallback? onTap) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(context.colors.lightPurple40),
      ),
      onPressed: onTap,
      child: BaseText(textKey, color: context.colors.purple),
    );
  }
}

class DayItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;

  const DayItem({
    super.key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? context.colors.purple : null,
        border: isToday
            ? Border.all(color: context.colors.purple, width: AppSizes.border2)
            : null,
      ),
      child: BaseText(
        '${date.day}',
        localized: false,
        fontSize: TypographyConst.labelMedium,
        color: isDisabled
            ? context.colors.buttonDisabled
            : isSelected
            ? Colors.white
            : context.colors.labelPrimary,
      ),
    );
  }
}
