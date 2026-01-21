import 'package:flutter/material.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/ui_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';

class TextInput extends StatefulWidget {
  final String? titleKey;
  final String? hintKey;
  final TextEditingController controller;
  final bool disabled;
  final ValueChanged<String>? onSubmit;
  final ValueChanged<bool>? onFocus;
  final ValueChanged<String>? onTextChanged;
  final String? errorText;
  final bool isValid;
  final int? maxLines;

  const TextInput({
    super.key,
    this.titleKey,
    this.hintKey,
    required this.controller,
    this.disabled = false,
    this.onSubmit,
    this.onFocus,
    this.onTextChanged,
    this.errorText,
    this.isValid = true,
    this.maxLines,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late FocusNode _focusNode;

  late final bool _isEditor;

  @override
  void initState() {
    super.initState();
    _isEditor = widget.maxLines != null && widget.maxLines! > 1;

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (widget.onFocus != null) {
        widget.onFocus!(_focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          textCapitalization: TextCapitalization.sentences,
          focusNode: _focusNode,
          onSubmitted: widget.onSubmit,
          autocorrect: false,
          textAlignVertical: _isEditor
              ? TextAlignVertical.top
              : TextAlignVertical.center,
          onChanged: widget.onTextChanged,
          enabled: !widget.disabled,
          maxLines: widget.maxLines ?? 1,
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          style: TextStyle(
            color: context.colors.labelPrimary,
            fontSize: TypographyConst.labelStandart,
            fontWeight: TypographyConst.wRegular,
          ),
          decoration: UiHelper.inputDecoration(
            context,
            isMultiline: _isEditor,
            isValid: widget.isValid,
            label: widget.titleKey != null
                ? BaseText.secondary(
                    widget.titleKey!,
                    fontWeight: TypographyConst.wSemiBold,
                    fontSize: TypographyConst.labelSmall,
                  )
                : null,
            hint: widget.hintKey != null
                ? _HintText(widget.hintKey!, _isEditor)
                : null,

            fillColor: widget.disabled
                ? context.colors.disable
                : context.colors.background,
          ),
        ),
        !widget.isValid
            ? Padding(
                padding: const EdgeInsets.only(top: AppSizes.spacing2),
                child: BaseText(
                  widget.errorText ?? "",
                  color: context.colors.error,
                  fontSize: TypographyConst.labelSmall,
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

class _HintText extends StatelessWidget {
  final String hintKey;
  final bool isEditor;

  const _HintText(this.hintKey, this.isEditor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isEditor ? AppSizes.spacing12 : 0),
      child: BaseText(
        hintKey,
        color: context.colors.labelHint,
        height: 1.2,
        maxLines: isEditor ? 4 : null,
      ),
    );
  }
}
