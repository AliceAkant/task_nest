import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_nest/core/shared_prefs/shared_preferences_extension.dart';
import 'package:task_nest/core/shared_prefs/shared_preferences_factory.dart';
import 'package:task_nest/domain/entities/daily_brief_settings.dart';
import 'package:task_nest/domain/entities/user_profile.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/infrastructure/localization/localization_config.dart';
import 'package:task_nest/infrastructure/routes/app_routes.dart';
import 'package:task_nest/presentation/blocs/localization/localization_cubit.dart';
import 'package:task_nest/presentation/blocs/settings/settings_cubit.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';
import 'package:task_nest/presentation/enum/app_svg.dart';
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<SettingsCubit>().refreshState();
    }
  }

  Future _goToProfile(BuildContext context, UserProfile user) async {
    await context.push(AppRoutes.profile, extra: user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBarCreator.generic(context, titleKey: LocaleKeys.settings),
      body: _dataState(context),
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

            if (kDebugMode) ...[
              TappableBox(
                backgroundColor: context.colors.error.withAlpha(40),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing12),
                  child: BaseText('Exit [DEBUG]'),
                ),
                onTap: () async {
                  var sh = await SharedPreferencesFactory.get();
                  sh.clearExcept([]);

                  if (context.mounted) {
                    context.go(AppRoutes.splash);
                  }
                },
              ),
            ],
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
              AssetsHelper.getSvgImage(AppSvg.heart, width: AppSizes.size24),
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
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final loaded = state is SettingsLoaded ? state : null;
        final isEnabled = loaded?.notificationsEnabled ?? false;
        final brief = loaded?.dailyBrief ?? const DailyBriefSettings.defaults();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacing12),
              child: Row(
                children: [
                  Expanded(child: BaseText(LocaleKeys.allow_notifications)),
                  Switcher(
                    value: isEnabled,
                    onChanged: (value) =>
                        context.read<SettingsCubit>().toggleNotifications(value),
                  ),
                ],
              ),
            ),
            if (isEnabled) ...[
              _separator(context),
              _dailyBriefView(context, brief),
            ],
          ],
        );
      },
    );
  }

  Widget _dailyBriefView(BuildContext context, DailyBriefSettings brief) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BaseText(
                      LocaleKeys.daily_brief,
                      fontWeight: TypographyConst.wSemiBold,
                    ),
                    const SizedBox(height: AppSizes.spacing2),
                    BaseText(
                      LocaleKeys.daily_brief_description,
                      fontSize: TypographyConst.labelMedium,
                      color: context.colors.labelSecondary,
                    ),
                  ],
                ),
              ),
              Switcher(
                value: brief.enabled,
                onChanged: (value) =>
                    context.read<SettingsCubit>().toggleDailyBrief(value),
              ),
            ],
          ),
          if (brief.enabled) ...[
            const SizedBox(height: AppSizes.spacing12),
            Row(
              children: [
                Expanded(child: BaseText(LocaleKeys.daily_brief_time)),
                TappableBox(
                  onTap: () => _pickDailyBriefTime(context, brief),
                  backgroundColor: context.colors.lightPurple40,
                  splashColor: context.colors.defaultSplash,
                  borderRadius: BorderRadius.circular(AppSizes.barRadius),
                  border: Border.all(
                    width: AppSizes.border1,
                    color: context.colors.borderFocused,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.spacing8,
                      horizontal: AppSizes.spacing12,
                    ),
                    child: BaseText(
                      _formatTime(brief.hour, brief.minute),
                      localized: false,
                      fontWeight: TypographyConst.wSemiBold,
                      color: context.colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDailyBriefTime(
    BuildContext context,
    DailyBriefSettings brief,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: brief.hour, minute: brief.minute),
    );
    if (picked != null && context.mounted) {
      context.read<SettingsCubit>().setDailyBriefTime(picked.hour, picked.minute);
    }
  }

  String _formatTime(int hour, int minute) {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Widget _separator(BuildContext context) {
    return Container(
      color: context.colors.lightGrey150,
      height: AppSizes.border1,
    );
  }

  Widget _theme(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.spacing8),
          child: Row(
            children: [
              _themeSegment(
                context,
                textKey: LocaleKeys.system,
                isSelected: mode == ThemeMode.system,
                onTap: () => context.read<ThemeCubit>().toggleSystem(),
              ),
              _themeSegment(
                context,
                textKey: LocaleKeys.light,
                icon: AppSvg.sun,
                isSelected: mode == ThemeMode.light,
                onTap: () => context.read<ThemeCubit>().toggleLight(),
              ),
              _themeSegment(
                context,
                textKey: LocaleKeys.dark,
                icon: AppSvg.moon,
                isSelected: mode == ThemeMode.dark,
                onTap: () => context.read<ThemeCubit>().toggleDark(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _themeSegment(
    BuildContext context, {
    required String textKey,
    AppSvg? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final fg = isSelected ? context.colors.purple : context.colors.labelSecondary;
    return Expanded(
      child: TappableBox(
        onTap: onTap,
        backgroundColor:
            isSelected ? context.colors.lightPurple40 : Colors.transparent,
        splashColor: context.colors.defaultSplash,
        borderRadius: BorderRadius.circular(AppSizes.barRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.spacing12,
            horizontal: AppSizes.spacing8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                AssetsHelper.getSvgImage(
                  icon,
                  width: AppSizes.size18,
                ),
                const SizedBox(width: AppSizes.spacing4),
              ],
              BaseText(
                textKey,
                color: fg,
                fontWeight: TypographyConst.wSemiBold,
                fontSize: TypographyConst.labelMedium,
              ),
            ],
          ),
        ),
      ),
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
