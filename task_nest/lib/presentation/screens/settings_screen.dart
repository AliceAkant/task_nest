import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_nest/core/shared_prefs/shared_preferences_extension.dart';
import 'package:task_nest/core/shared_prefs/shared_preferences_factory.dart';
import 'package:task_nest/domain/entities/user_profile.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/infrastructure/localization/localization_config.dart';
import 'package:task_nest/infrastructure/routes/app_routes.dart';
import 'package:task_nest/presentation/blocs/localization/localization_cubit.dart';
import 'package:task_nest/presentation/blocs/settings/settings_cubit.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/assets_helper.dart';
import 'package:task_nest/presentation/widgets/cards/avatar_card.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';
import 'package:task_nest/presentation/widgets/title_block.dart';
import 'package:task_nest/presentation/widgets/views/members_list_view.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/theme_cubit.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/helpers/app_bar_creator.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/checkable_item.dart';
import 'package:task_nest/presentation/widgets/switcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future _goToProfile(BuildContext context, UserProfile user) async {
    await context.push(AppRoutes.profile, extra: user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBarCreator.generic(context, titleKey: LocaleKeys.settings),

      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return _dataState(context);
        },
      ),
    );
  }

  Widget _dataState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHGap),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _greeting(context),

            const SizedBox(height: AppSizes.spacing8),
            // PROFILE
            _profileView(context),

            // APPEARANCE
            _settingsBlock(
              titleKey: LocaleKeys.appearance,
              child: _theme(context),
            ),
            const SizedBox(height: AppSizes.spacing16),
            // LOCALE
            _settingsBlock(
              titleKey: LocaleKeys.language,
              child: _locale(context),
            ),
            const SizedBox(height: AppSizes.spacing16),
            // MEMBERS
            _settingsBlock(
              titleKey: LocaleKeys.members,
              child: MembersListView(separator: _separator(context)),
            ),
            const SizedBox(height: AppSizes.spacing16),
            // NOTIFICATIONS
            _settingsBlock(
              titleKey: LocaleKeys.notifications,
              child: _notificationsView(context),
            ),
            // TODO: remove (test option)
            TappableBox(
              backgroundColor: context.colors.error.withAlpha(40),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacing12),
                child: BaseText('Exit'),
              ),
              onTap: () async {
                var sh = await SharedPreferencesFactory.get();
                sh.clearExcept([]);

                if (context.mounted) {
                  context.go(AppRoutes.splash);
                }
              },
            ),
            const SizedBox(height: AppSizes.spacing24),
          ],
        ),
      ),
    );
  }

  Widget _settingsBlock({required String titleKey, required Widget child}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.spacing16),
      child: TitleBlock(outlined: true, titleKey: titleKey, child: child),
    );
  }

  Widget _greeting(BuildContext context) {
    return BlocBuilder<UserCubit, UserProfile?>(
      builder: (context, state) {
        if (state != null) {
          return Row(
            children: [
              BaseText(
                context.tr(
                  LocaleKeys.greeting,
                  namedArgs: {'name': state.name},
                ),
                localized: false,
                fontWeight: TypographyConst.wSemiBold,
                fontSize: TypographyConst.labelLarge,
              ),
              AssetsHelper.getSvgImage("heart", width: AppSizes.size24),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _profileView(BuildContext context) {
    return BlocBuilder<UserCubit, UserProfile?>(
      builder: (context, state) {
        if (state != null) {
          return Padding(
            padding: const EdgeInsets.only(
              top: AppSizes.spacing8,
              bottom: AppSizes.spacing16,
            ),
            child: TappableBox(
              backgroundColor: context.colors.lightPurple40,
              onTap: () => _goToProfile(context, state),
              splashColor: context.colors.lightPurple40,
              border: Border.all(
                width: AppSizes.border2,
                color: context.colors.borderFocused,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppSizes.barRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacing8),
                child: Row(
                  children: [
                    AvatarCard(theme: null, avatar: state.avatar),
                    const SizedBox(width: AppSizes.spacing8),
                    Expanded(
                      child: BaseText(
                        LocaleKeys.my_profile,
                        color: context.colors.purple,
                        fontWeight: TypographyConst.wSemiBold,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: context.colors.purple,
                      size: AppSizes.size28,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _notificationsView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing12),
      child: Row(
        children: [
          Expanded(child: BaseText(LocaleKeys.allow_notifications)),
          Switcher(initialValue: false),
        ],
      ),
    );
  }

  Widget _separator(BuildContext context) {
    return Container(
      color: context.colors.lightGrey150,
      height: AppSizes.border1,
    );
  }

  Widget _theme(BuildContext context) {
    return Column(
      children: [
        CheckableItem(
          textKey: LocaleKeys.dark_theme,
          icon: 'moon',
          isSelected: context.read<ThemeCubit>().state == ThemeMode.dark,
          onTap: () => context.read<ThemeCubit>().toggleDark(),
        ),
        _separator(context),
        CheckableItem(
          textKey: LocaleKeys.light_theme,
          icon: 'sun',
          isSelected: context.read<ThemeCubit>().state == ThemeMode.light,
          onTap: () => context.read<ThemeCubit>().toggleLight(),
        ),
      ],
    );
  }

  Widget _locale(BuildContext context) {
    final localizations = LocalizationConfig.localizations;
    return Column(
      children: List.generate(localizations.length, (index) {
        final l = localizations[index];
        return Column(
          children: [
            if (index > 0) _separator(context),
            CheckableItem(
              textKey: l.name,
              isSelected: context.locale == l.locale,
              onTap: () {
                if (context.locale != l.locale) {
                  context.read<LocalizationCubit>().changeLocale(l);
                }
              },
            ),
          ],
        );
      }),
    );
  }
}
