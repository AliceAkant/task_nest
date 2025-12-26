import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/presentation/blocs/profile/profile_cubit.dart';
import 'package:task_nest/presentation/blocs/profile/profile_state.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';
import 'package:task_nest/presentation/enum/schedule_filter_mode.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/popup_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/helpers/app_bar_creator.dart';
import 'package:task_nest/presentation/widgets/cards/avatar_card.dart';
import 'package:task_nest/presentation/widgets/title_block.dart';
import 'package:task_nest/presentation/widgets/radio_list.dart';
import 'package:task_nest/presentation/widgets/rounded_button.dart';
import 'package:task_nest/presentation/widgets/text_input.dart';
import 'package:task_nest/presentation/widgets/views/avatar_selection_view.dart';

class ProfileScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  ProfileScreen({super.key, required String? username}) {
    _nameController.text = username ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(userCubit: context.read<UserCubit>()),
      child: BlocConsumer<ProfileCubit, ProfileState>(
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
          final cubit = context.read<ProfileCubit>();

          return Scaffold(
            backgroundColor: context.colors.background,
            appBar: AppBarCreator.modal(
              context,
              isCloseDisabled: state.isSaving,
              titleKey: LocaleKeys.profile,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.pageHGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAME
                    TitleBlock(
                      titleKey: LocaleKeys.name,
                      child: TextInput(
                        key: ValueKey('username_key'),
                        hintKey: LocaleKeys.member_name_example,
                        controller: _nameController,
                        isValid: !state.validationMode || state.isValid,
                        errorText: LocaleKeys.empty_field_error,
                        onTextChanged: cubit.nameChanged,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing16),
                    // AVATARS
                    TitleBlock(
                      titleKey: LocaleKeys.avatar,
                      child: AvatarSelectionView(
                        excludeNone: true,
                        seclectedItem: state.avatar,
                        onSelect: (a) => cubit.avatarChanged(a),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacing16),
                    // PREVIEW
                    TitleBlock(
                      titleKey: LocaleKeys.schedule_member_view,
                      child: AvatarCard(
                        theme: null,
                        avatar: state.avatar,
                        size: AvatarSize.huge,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing16),
                    // FILTER MODE
                    TitleBlock(
                      titleKey: LocaleKeys.schedule_filter_mode_title,
                      child: RadioList(
                        items: DefaultScheduleFilterMode.values,
                        selected: state.scheduleFilterMode,
                        onSelected: (value) => cubit.scheduleModeChanged(value),
                        labelBuilder: (o) => o.titleKey,
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacing24),

                    // BUTTONS
                    RoundedButton(
                      textKey: LocaleKeys.save,
                      onTap: () {
                        if (!state.isSaving) {
                          cubit.save();
                        }
                      },
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
}
