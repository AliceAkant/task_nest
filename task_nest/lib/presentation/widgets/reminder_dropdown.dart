import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:task_nest/domain/enums/reminder_offset.dart';
import 'package:task_nest/presentation/enum/app_svg.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/assets_helper.dart';
import 'package:task_nest/presentation/helpers/ui_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';

class ReminderDropdown extends StatefulWidget {
  final Set<ReminderOffset> selectedReminders;
  final bool isRussian;
  final String noReminderKey;
  final Future<void> Function(ReminderOffset) onToggled;
  final VoidCallback onNoReminderSelected;

  const ReminderDropdown({
    super.key,
    required this.selectedReminders,
    required this.isRussian,
    required this.noReminderKey,
    required this.onToggled,
    required this.onNoReminderSelected,
  });

  @override
  State<ReminderDropdown> createState() => _ReminderDropdownState();
}

class _ReminderDropdownState extends State<ReminderDropdown>
    with SingleTickerProviderStateMixin {
  late final AnimationController _arrowController;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  bool _isFocused = false;
  bool _thumbVisible = false;
  final ScrollController _scrollController = ScrollController();

  static const double _overlayTopSpace = AppSizes.spacing4;
  static const double _itemHeight = AppSizes.size48;
  static const double _listSpacing = AppSizes.spacing8;
  static const double _visibleItems = 3.5;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _openDropdown();
    } else {
      _closeDropdown();
    }
  }

  void _openDropdown() {
    _thumbVisible = false;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _arrowController.forward();
    _setFocus(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _thumbVisible = true;
      _overlayEntry?.markNeedsBuild();
    });
  }

  void _closeDropdown() {
    _thumbVisible = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _arrowController.reverse();
    _setFocus(false);
  }

  void _setFocus(bool value) {
    if (_isFocused != value) {
      setState(() => _isFocused = value);
    }
  }

  Future<void> _handleToggle(ReminderOffset reminder) async {
    await widget.onToggled(reminder);
    _overlayEntry?.markNeedsBuild();
  }

  void _handleNoReminder() {
    widget.onNoReminderSelected();
    _overlayEntry?.markNeedsBuild();
  }

  @override
  void didUpdateWidget(ReminderDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedReminders != widget.selectedReminders) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _overlayEntry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _scrollController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  String _displayText(BuildContext context) {
    if (widget.selectedReminders.isEmpty) {
      return context.tr(widget.noReminderKey);
    }
    return widget.selectedReminders
        .map((r) => widget.isRussian ? r.labelRu() : r.labelEn())
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final isNone = widget.selectedReminders.isEmpty;
    final text = _displayText(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: InputDecorator(
          isFocused: _isFocused,
          decoration: UiHelper.inputDecoration(context),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: TypographyConst.fontFamily,
                    fontSize: TypographyConst.labelStandart,
                    fontWeight: isNone
                        ? TypographyConst.wRegular
                        : TypographyConst.wSemiBold,
                    color: isNone
                        ? context.colors.labelSecondary
                        : context.colors.purple,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacing2),
              RotationTransition(
                turns: Tween(begin: 0.5, end: 0.0).animate(_arrowController),
                child: Transform.rotate(
                  angle: -pi / 2,
                  child: const Icon(Icons.chevron_right),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    // +1 for the "Don't remind" item
    final totalItems = ReminderOffset.values.length + 1;
    final maxHeight = _visibleItems * _itemHeight + _listSpacing * 2;

    return OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + _overlayTopSpace,
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + _overlayTopSpace),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.background,
                    border: Border.all(
                      width: AppSizes.border1,
                      color: context.colors.borderSecondary,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppSizes.cardRadius),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(80),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    child: RawScrollbar(
                      controller: _scrollController,
                      thumbVisibility: _thumbVisible,
                      thickness: 3,
                      radius: const Radius.circular(4),
                      child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(vertical: _listSpacing),
                      itemCount: totalItems,
                      itemBuilder: (ctx, index) {
                        // index 0 = "Don't remind", index 1+ = offsets
                        if (index == 0) {
                          final isSelected =
                              widget.selectedReminders.isEmpty;
                          final label = ctx.tr(widget.noReminderKey);
                          return _DropdownItem(
                            label: label,
                            isSelected: isSelected,
                            onTap: _handleNoReminder,
                          );
                        }

                        final reminder = ReminderOffset.values[index - 1];
                        final isSelected =
                            widget.selectedReminders.contains(reminder);
                        final label = widget.isRussian
                            ? reminder.labelRu()
                            : reminder.labelEn();

                        return _DropdownItem(
                          label: label,
                          isSelected: isSelected,
                          onTap: () => _handleToggle(reminder),
                        );
                      },
                    ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DropdownItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _ReminderDropdownState._itemHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing8),
        child: TappableBox(
          onTap: onTap,
          splashColor: context.colors.defaultSplash,
          backgroundColor: isSelected ? context.colors.lightPurple40 : null,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing12,
              vertical: AppSizes.spacing4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: TypographyConst.fontFamily,
                      fontSize: TypographyConst.labelStandart,
                      fontWeight: isSelected
                          ? TypographyConst.wSemiBold
                          : TypographyConst.wRegular,
                      color: isSelected
                          ? context.colors.purple
                          : context.colors.labelPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  AssetsHelper.getSvgImage(
                    AppSvg.checkMark,
                    width: AppSizes.size18,
                    color: context.colors.purple,
                  )
                else
                  const SizedBox(width: AppSizes.size18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
