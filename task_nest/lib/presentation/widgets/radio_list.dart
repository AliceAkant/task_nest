import 'package:flutter/material.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';

class RadioList<T> extends StatelessWidget {
  final List<T> items;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T) labelBuilder;

  const RadioList({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        final isSelected = item == selected;
        return TappableBox(
          splashColor: context.colors.lightPurple40,
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          onTap: () => onSelected(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing8),
            child: Row(
              children: [
                Container(
                  width: AppSizes.size24,
                  height: AppSizes.size24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? context.colors.borderFocused
                          : context.colors.borderPrimary,
                      width: AppSizes.border2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            margin: EdgeInsets.all(AppSizes.spacing2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colors.purple,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSizes.spacing8),
                BaseText(labelBuilder(item)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
