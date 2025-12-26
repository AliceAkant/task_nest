import 'package:flutter/material.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/ui_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';

class TimePicker extends StatefulWidget {
  final TimeOfDay? initialTime;
  final String? errorText;
  final bool isValid;

  final ValueChanged<TimeOfDay>? onTimeChanged;

  const TimePicker({
    super.key,
    this.initialTime,
    this.errorText,
    this.isValid = true,
    this.onTimeChanged,
  });

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    _selectedTime = widget.initialTime;
    super.initState();
  }

  Future _openPicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
      widget.onTimeChanged?.call(_selectedTime!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = _selectedTime != null
        ? _selectedTime!.format(context)
        : "-- | --";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TappableBox(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          onTap: _openPicker,
          child: InputDecorator(
            decoration: UiHelper.inputDecoration(
              context,
              isValid: widget.isValid,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.query_builder,
                  color: context.colors.labelSecondary,
                  size: AppSizes.size28,
                ),
                const SizedBox(width: AppSizes.spacing12),
                BaseText.primary(displayDate, localized: false),
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
