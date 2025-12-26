import 'package:flutter/material.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/presentation/enum/button_kind.dart';
import 'package:task_nest/presentation/enum/form_mode.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/widgets/bordered_button.dart';
import 'package:task_nest/presentation/widgets/rounded_button.dart';

class FormButtonsRow extends StatelessWidget {
  final FormMode mode;
  final String addTextKey;
  final String saveTextKey;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;
  final bool isSaving;

  const FormButtonsRow({
    super.key,
    required this.mode,
    required this.addTextKey,
    required this.saveTextKey,
    this.onSave,
    this.onDelete,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Delete
        mode == FormMode.edit
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSizes.spacing8),
                  child: BorderedButton(
                    textKey: LocaleKeys.delete,
                    kind: ButtonKind.error,
                    onTap: isSaving ? null : onDelete,
                  ),
                ),
              )
            : const SizedBox(),
        // Save/Add
        Expanded(
          child: RoundedButton(
            textKey: mode == FormMode.add ? addTextKey : saveTextKey,
            onTap: isSaving ? null : onSave,
          ),
        ),
      ],
    );
  }
}
