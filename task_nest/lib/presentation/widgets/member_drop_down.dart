import 'dart:math';
import 'package:flutter/material.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/ui_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/cards/avatar_card.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';

class MemberDropdown extends StatefulWidget {
  final List<Member> members;
  final Member? initialValue;
  final String? hintKey;
  final void Function(Member)? onChanged;

  const MemberDropdown({
    super.key,
    required this.members,
    this.initialValue,
    this.hintKey,
    this.onChanged,
  });

  @override
  State<MemberDropdown> createState() => _MemberDropdownState();
}

class _MemberDropdownState extends State<MemberDropdown>
    with SingleTickerProviderStateMixin {
  late final AnimationController _arrowController;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  bool _isFocused = false;
  Member? _selectedItem;

  static const double _overlayTopSpace = AppSizes.spacing4;
  static const double _itemHeight = AppSizes.size54;
  static const double _listSpacing = AppSizes.spacing8;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _selectedItem = widget.initialValue;
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _openDropdown();
    } else {
      _closeDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _arrowController.forward();
    _setFocus(true);
  }

  void _closeDropdown() {
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

  void _select(Member member) {
    if (_selectedItem?.id != member.id) {
      setState(() => _selectedItem = member);
      widget.onChanged?.call(member);
    }
    _closeDropdown();
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: _selectedItem != null
                    ? _SelectedItemView(member: _selectedItem!)
                    : (widget.hintKey != null
                          ? BaseText(
                              widget.hintKey!,
                              color: context.colors.labelHint,
                            )
                          : const SizedBox()),
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

    final maxHeight = widget.members.length <= 3
        ? widget.members.length * _itemHeight + _listSpacing * 2
        : 3 * _itemHeight;

    return OverlayEntry(
      builder: (context) => Stack(
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
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: _listSpacing,
                      ),
                      itemCount: widget.members.length,
                      itemBuilder: (context, index) => _MemberItemView(
                        member: widget.members[index],
                        onSelect: _select,
                        selectedId: _selectedItem?.id,
                        height: _itemHeight,
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

class _SelectedItemView extends StatelessWidget {
  final Member member;
  const _SelectedItemView({required this.member});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AvatarCard(
          theme: member.theme,
          avatar: member.avatar,
          size: AvatarSize.small,
        ),
        const SizedBox(width: AppSizes.spacing8),
        Expanded(child: BaseText.primary(member.name)),
      ],
    );
  }
}

class _MemberItemView extends StatelessWidget {
  final Member member;
  final void Function(Member) onSelect;
  final int? selectedId;
  final double height;

  const _MemberItemView({
    required this.member,
    required this.onSelect,
    required this.selectedId,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedId == member.id;
    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.spacing8),
        child: TappableBox(
          onTap: () => onSelect(member),
          splashColor: context.colors.defaultSplash,
          backgroundColor: isSelected ? context.colors.lightPurple40 : null,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: Padding(
            padding: const EdgeInsetsGeometry.symmetric(
              horizontal: AppSizes.spacing12,
              vertical: AppSizes.spacing4,
            ),
            child: Row(
              children: [
                AvatarCard(
                  theme: member.theme,
                  avatar: member.avatar,
                  size: AvatarSize.small,
                ),
                const SizedBox(width: AppSizes.spacing8),
                Expanded(child: BaseText(member.name, localized: false)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
