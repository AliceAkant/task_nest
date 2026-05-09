import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/infrastructure/routes/app_routes.dart';
import 'package:task_nest/presentation/blocs/greeting/greeting_cubit.dart';
import 'package:task_nest/presentation/blocs/greeting/greeting_state.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/rounded_button.dart';
import 'package:task_nest/presentation/widgets/text_input.dart';
import 'package:task_nest/presentation/widgets/views/avatar_selection_view.dart';

class GreetingScreen extends StatefulWidget {
  const GreetingScreen({super.key});

  @override
  State<GreetingScreen> createState() => _GreetingScreenState();
}

class _GreetingScreenState extends State<GreetingScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GreetingCubit(context.read<UserCubit>()),
      child: BlocConsumer<GreetingCubit, GreetingState>(
        listener: (context, state) {
          if (state.completed == true) {
            context.go(AppRoutes.schedule);
          }
        },
        builder: (context, state) {
          final cubit = context.read<GreetingCubit>();

          return Scaffold(
            backgroundColor: context.colors.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.pageHGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BaseText(
                      LocaleKeys.greeting_title,
                      fontWeight: TypographyConst.wSemiBold,
                      fontSize: TypographyConst.labelLarge,
                      maxLines: 3,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.spacing16),
                    // NAME
                    BaseText.secondary(
                      LocaleKeys.greeting_name_title,
                      fontWeight: TypographyConst.wSemiBold,
                      maxLines: 3,
                      height: 1.2,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    TextInput(
                      key: ValueKey('username_key'),
                      hintKey: LocaleKeys.greeting_name_placeholder,
                      controller: _nameController,
                      isValid: !state.validationMode || state.isValid,
                      errorText: LocaleKeys.empty_field_error,
                      onTextChanged: cubit.nameChanged,
                    ),
                    const SizedBox(height: AppSizes.spacing24),
                    // AVATARS
                    BaseText.secondary(
                      LocaleKeys.greeting_avatar_title,
                      fontWeight: TypographyConst.wSemiBold,
                      maxLines: 3,
                      height: 1.2,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.spacing8),

                    AvatarSelectionView(
                      center: true,
                      excludeNone: true,
                      seclectedItem: state.avatar,
                      onSelect: (a) => cubit.avatarChanged(a),
                    ),

                    const SizedBox(height: AppSizes.spacing24),
                    // BUTTONS
                    Row(
                      children: [
                        const SizedBox(width: AppSizes.spacing8),
                        Expanded(
                          child: RoundedButton(
                            textKey: LocaleKeys.save,
                            onTap: () {
                              if (!state.isSaving) {
                                cubit.save();
                              }
                            },
                          ),
                        ),
                      ],
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
