import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/extensions/date_time_extension.dart';
import 'package:task_nest/presentation/extensions/string_extension.dart';
import 'package:task_nest/presentation/helpers/ui_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';
import 'package:task_nest/presentation/widgets/views/calendar_view.dart';

class DatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? startDate;

  /// If not null - will be shown events count badge near date
  final Map<DateTime, int>? eventsCountMap;
  final String? errorText;
  final bool isValid;
  final bool showResetButton;

  final Function(DateTime?)? onDateChanged;

  const DatePicker({
    super.key,
    this.initialDate,
    this.startDate,
    this.eventsCountMap,
    this.errorText,
    this.isValid = true,
    this.showResetButton = true,
    this.onDateChanged,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? _selectedDate;

  @override
  void initState() {
    _selectedDate = widget.initialDate;
    super.initState();
  }

  Future _showDatePicker(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          elevation: 12,
          shadowColor: context.colors.defaultShadow,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.popupHGap,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppSizes.popupRadius),
            ),
          ),
          backgroundColor: context.colors.background,
          child: CalendarView(
            initialDate: _selectedDate,
            firstDate: widget.startDate ?? DateTime.now().dateOnly,
            lastDate: DateTime(2100),
            dayEventCountMap: widget.eventsCountMap,
            resetAvailable: widget.showResetButton,
            onSubmit: (date) => Navigator.pop(ctx, date),
            onCancel: () => Navigator.pop(ctx, null),
            onReset: () => Navigator.pop(ctx, true),
          ),
        );
      },
    );

    if (result == true) {
      setState(() => _selectedDate = null);
      widget.onDateChanged?.call(_selectedDate);
    } else if (result is DateTime && result != _selectedDate) {
      setState(() => _selectedDate = result);
      widget.onDateChanged?.call(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final formatter = DateFormat('MMM d', locale.toString());
    final displayDate = _selectedDate != null
        ? formatter.format(_selectedDate!).firstCharUppercase()
        : "-- | --";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TappableBox(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          onTap: () => _showDatePicker(context),
          child: InputDecorator(
            decoration: UiHelper.inputDecoration(
              context,
              isValid: widget.isValid,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: context.colors.labelSecondary,
                  size: AppSizes.size28,
                ),
                const SizedBox(width: AppSizes.spacing12),

                BaseText(displayDate, localized: false),
              ],
            ),
          ),
        ),

        if (!widget.isValid)
          Padding(
            padding: EdgeInsets.only(top: AppSizes.spacing2),
            child: BaseText(
              widget.errorText ?? "",
              color: context.colors.error,
              fontSize: TypographyConst.labelSmall,
            ),
          ),
      ],
    );
  }
}
