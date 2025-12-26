import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/presentation/blocs/member_form/member_form_cubit.dart';
import 'package:task_nest/presentation/blocs/member_form/member_form_state.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/presentation/enum/form_mode.dart';
import 'package:task_nest/domain/enums/member_theme.dart';
import 'package:task_nest/presentation/enum/popup_result.dart';
import 'package:task_nest/presentation/enum/popup_style.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/popup_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/helpers/app_bar_creator.dart';
import 'package:task_nest/presentation/widgets/cards/avatar_card.dart';
import 'package:task_nest/presentation/widgets/form_buttons_row.dart';
import 'package:task_nest/presentation/widgets/title_block.dart';
import 'package:task_nest/presentation/widgets/text_input.dart';
import 'package:task_nest/presentation/widgets/views/avatar_selection_view.dart';
import 'package:task_nest/presentation/widgets/views/member_theme_selection_view.dart';

class MemberFormScreen extends StatelessWidget {
  final FormMode mode;
  final Member? initialMember;
  late final TextEditingController _nameController;

  MemberFormScreen({super.key, required this.mode, this.initialMember}) {
    _nameController = TextEditingController(text: initialMember?.name ?? '');
  }

  MemberFormScreen.add({super.key})
    : mode = FormMode.add,
      initialMember = null {
    _nameController = TextEditingController();
  }

  MemberFormScreen.edit({super.key, required Member member})
    : mode = FormMode.edit,
      initialMember = member {
    _nameController = TextEditingController(text: member.name);
  }

  Future _deleteMember(BuildContext context) async {
    final result = await PopupHelper.showTwoActions(
      context,
      style: PopupStyle.error,
      title: LocaleKeys.delete_member_popup_title,
      message: LocaleKeys.delete_member_popup_message,
      submitText: LocaleKeys.cancel,
      cancelText: LocaleKeys.delete,
      iconSource: 'attention',
    );
    if (context.mounted && result == PopupResult.cancel) {
      final cubit = context.read<MemberFormCubit>();
      if (!cubit.state.isSaving) {
        cubit.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MemberFormCubit(mode, initialMember),
      child: BlocConsumer<MemberFormCubit, MemberFormState>(
        listener: (context, state) {
          if (state.completed == true) {
            context.pop(true);
          }
          if (state.hasError) {
            PopupHelper.showErrorSnackBar(
              context,
              errorMessage: state.errorMessage,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<MemberFormCubit>();

          return Scaffold(
            backgroundColor: context.colors.background,
            appBar: AppBarCreator.modal(
              context,
              isCloseDisabled: state.isSaving,
              titleKey: mode == FormMode.add
                  ? LocaleKeys.add_member
                  : LocaleKeys.edit_member,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.pageHGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAME
                    TitleBlock(
                      titleKey: LocaleKeys.member_name,
                      child: TextInput(
                        key: ValueKey('member_name_key'),
                        hintKey: LocaleKeys.member_name_example,
                        controller: _nameController,
                        isValid: !state.validationMode || state.isValid,
                        errorText: LocaleKeys.empty_field_error,
                        onTextChanged: cubit.nameChanged,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing16),

                    // COLOR
                    TitleBlock(
                      titleKey: LocaleKeys.choose_color,
                      child: MemberThemeSelectionView(
                        seclectedItem: state.memberTheme,
                        onSelect: (t) => cubit.colorChanged(t),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacing16),

                    // AVATARS
                    TitleBlock(
                      titleKey: LocaleKeys.choose_avatar,
                      child: AvatarSelectionView(
                        seclectedItem: state.avatar,
                        onSelect: (a) => cubit.avatarChanged(a),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacing16),
                    // PREVIEW
                    TitleBlock(
                      titleKey: LocaleKeys.schedule_member_view,
                      child: _preview(
                        state.memberTheme,
                        state.avatar,
                        state.name,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing24),

                    // BUTTONS
                    FormButtonsRow(
                      mode: mode,
                      addTextKey: LocaleKeys.add_member,
                      saveTextKey: LocaleKeys.save,
                      onSave: () => cubit.save(),
                      onDelete: () => _deleteMember(context),
                      isSaving: state.isSaving,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _preview(MemberTheme theme, Avatar avatar, String name) {
    return AvatarCard(theme: theme, avatar: avatar, size: AvatarSize.huge);
  }
}
