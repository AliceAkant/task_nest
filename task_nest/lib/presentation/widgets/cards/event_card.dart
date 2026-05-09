import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/enums/member_theme.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/cards/avatar_card.dart';
import 'package:task_nest/presentation/widgets/tappable_box.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final bool isPassed;
  final Function(Event)? onTap;

  const EventCard({
    required this.event,
    this.isPassed = true,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TappableBox(
      onTap: () => onTap?.call(event),
      splashColor: context.colors.lightPurple40,
      backgroundColor: isPassed
          ? context.colors.disable
          : event.member?.theme.scheduleBG(Theme.of(context).brightness) ??
                context.colors.background,
      border: Border.all(
        width: AppSizes.border1,
        color: context.colors.borderSecondary,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(AppSizes.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // INFO
            Expanded(child: _eventInfo(context)),

            // AVATAR
            Padding(
              padding: const EdgeInsets.only(left: AppSizes.spacing8),
              child: _avatar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventInfo(BuildContext context) {
    final color = isPassed
        ? context.colors.labelDisable
        : context.colors.labelPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        BaseText(
          event.title,
          color: color,
          fontWeight: TypographyConst.wSemiBold,
          maxLines: 2,
          height: 1.2,
          localized: false,
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSizes.spacing2),
          child: BaseText(
            event.notes != null && event.notes!.isNotEmpty
                ? event.notes!
                : 'Без заметок',
            color: color,
            fontSize: TypographyConst.labelMedium,
            height: 1.2,
            maxLines: 2,
            localized: false,
          ),
        ),
        if (event.member != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.spacing4),
            child: _memberName(context, event.member!),
          ),
      ],
    );
  }

  Widget _avatar(BuildContext context) {
    if (event.member != null) {
      return AvatarCard(
        theme: event.member!.theme,
        avatar: event.member!.avatar,
        disabled: isPassed,
      );
    } else {
      var user = context.read<UserCubit>().state;
      if (user != null) {
        return AvatarCard(theme: null, avatar: user.avatar, disabled: isPassed);
      } else {
        return const SizedBox();
      }
    }
  }

  Widget _memberName(BuildContext context, Member member) {
    final color = isPassed
        ? context.colors.labelDisable
        : context.colors.labelPrimary;
    return BaseText(
      context.tr(LocaleKeys.member_name_show, namedArgs: {'name': member.name}),
      color: color,
      fontSize: TypographyConst.labelMedium,
      height: 1.2,
      localized: false,
    );
  }
}
