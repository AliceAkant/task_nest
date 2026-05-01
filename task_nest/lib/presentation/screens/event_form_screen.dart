import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_nest/domain/entities/event.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/infrastructure/localization/locale_keys.dart';
import 'package:task_nest/presentation/blocs/event_form/event_form_cubit.dart';
import 'package:task_nest/presentation/blocs/event_form/event_form_state.dart';
import 'package:task_nest/presentation/blocs/members/members_cubit.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';
import 'package:task_nest/presentation/enum/app_svg.dart';
import 'package:task_nest/presentation/enum/form_mode.dart';
import 'package:task_nest/presentation/enum/popup_result.dart';
import 'package:task_nest/presentation/enum/popup_style.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';
import 'package:task_nest/presentation/helpers/popup_helper.dart';
import 'package:task_nest/presentation/theme/app_sizes.dart';
import 'package:task_nest/presentation/theme/typography.dart';
import 'package:task_nest/presentation/helpers/app_bar_creator.dart';
import 'package:task_nest/presentation/widgets/base_text.dart';
import 'package:task_nest/presentation/widgets/cards/avatar_card.dart';
import 'package:task_nest/presentation/widgets/date_picker.dart';
import 'package:task_nest/presentation/widgets/form_buttons_row.dart';
import 'package:task_nest/presentation/widgets/states/load_members_error_state_view.dart';
import 'package:task_nest/presentation/widgets/title_block.dart';
import 'package:task_nest/presentation/widgets/member_drop_down.dart';
import 'package:task_nest/presentation/widgets/reminder_dropdown.dart';
import 'package:task_nest/presentation/widgets/switcher.dart';
import 'package:task_nest/presentation/widgets/text_input.dart';
import 'package:task_nest/presentation/widgets/time_picker.dart';

class EventFormScreen extends StatefulWidget {
  final FormMode mode;
  final Event? initialEvent;
  final DateTime? initialDate;

  const EventFormScreen({
    super.key,
    required this.mode,
    this.initialEvent,
    this.initialDate,
  });

  const EventFormScreen.add({super.key, this.initialDate})
    : mode = FormMode.add,
      initialEvent = null;

  const EventFormScreen.edit({super.key, required Event event})
    : mode = FormMode.edit,
      initialEvent = event,
      initialDate = null;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialEvent?.title ?? '',
    );
    _noteController = TextEditingController(
      text: widget.initialEvent?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future _deleteEvent(BuildContext context) async {
    final result = await PopupHelper.showTwoActions(
      context,
      style: PopupStyle.error,
      title: LocaleKeys.delete_event_popup_title,
      message: LocaleKeys.delete_event_popup_message,
      submitText: LocaleKeys.delete,
      cancelText: LocaleKeys.cancel,
      iconSource: AppSvg.attention,
    );
    if (context.mounted && result == PopupResult.submit) {
      final cubit = context.read<EventFormCubit>();
      if (!cubit.state.isSaving) {
        cubit.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventFormCubit(
        widget.mode,
        widget.initialEvent,
        widget.initialDate,
      ),
      child: BlocConsumer<EventFormCubit, EventFormState>(
        listenWhen: (previous, next) =>
            (previous.completed != true && next.completed == true) ||
            (previous.hasError != true && next.hasError == true),
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
          final cubit = context.read<EventFormCubit>();

          return Scaffold(
            backgroundColor: context.colors.background,
            appBar: AppBarCreator.modal(
              context,
              isCloseDisabled: state.isSaving,
              titleKey: widget.mode == FormMode.add
                  ? LocaleKeys.add_event
                  : LocaleKeys.edit_event,
            ),

            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.pageHGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // TITLE
                    TitleBlock(
                      titleKey: LocaleKeys.event_title,
                      child: TextInput(
                        key: const ValueKey('event_title_key'),
                        hintKey: LocaleKeys.event_title_example,
                        controller: _titleController,
                        isValid: !state.validationMode || state.isTitleValid,
                        errorText: LocaleKeys.empty_field_error,
                        onTextChanged: cubit.titleChanged,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing16),

                    // DATE TIME
                    TitleBlock(
                      titleKey: LocaleKeys.date_time,
                      child: Row(
                        children: [
                          Expanded(
                            child: DatePicker(
                              initialDate: state.date,
                              showResetButton: false,
                              onDateChanged: (date) {
                                if (date != null) {
                                  cubit.dateChanged(
                                    date.year,
                                    date.month,
                                    date.day,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacing8),
                          Expanded(
                            child: TimePicker(
                              initialTime: TimeOfDay(
                                hour: state.date.hour,
                                minute: state.date.minute,
                              ),
                              onTimeChanged: (time) =>
                                  cubit.timeChanged(time.hour, time.minute),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing16),

                    // REMINDERS
                    _remindersView(context, state, cubit),

                    const SizedBox(height: AppSizes.spacing16),

                    // MEMBER
                    _assignView(context),

                    // NOTE
                    TitleBlock(
                      titleKey: LocaleKeys.notes,
                      child: TextInput(
                        key: const ValueKey('event_notes_key'),
                        hintKey: LocaleKeys.notes_placeholder,
                        controller: _noteController,
                        maxLines: 4,
                        onTextChanged: cubit.notesChanged,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing16),

                    // BUTTONS
                    const SizedBox(height: AppSizes.spacing24),
                    FormButtonsRow(
                      mode: widget.mode,
                      addTextKey: LocaleKeys.add_event,
                      saveTextKey: LocaleKeys.save,
                      onSave: () => cubit.save(),
                      onDelete: () => _deleteEvent(context),
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

  Widget _assignView(BuildContext context) {
    final cubit = context.read<EventFormCubit>();

    return BlocBuilder<MembersCubit, MembersState>(
      builder: (context, memberState) {
        final members = memberState is DataLoaded
            ? memberState.members
            : <Member>[];
        final hasMembers = members.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSizes.spacing8),
            _assignToMeView(
              context,
              cubit.state.assignToMe,
              hasMembers: hasMembers,
              (value) => cubit.assignToMeChanged(value),
            ),

            if (!cubit.state.assignToMe)
              if (memberState is DataLoaded && hasMembers)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSizes.spacing8),
                    TitleBlock(
                      titleKey: LocaleKeys.choose_member,
                      child: MemberDropdown(
                        members: members,
                        initialValue: cubit.state.assignedMember,
                        hintKey: LocaleKeys.select_member,
                        onChanged: cubit.memberChanged,
                      ),
                    ),
                  ],
                )
              else if (memberState is LoadError)
                LoadMembersErrorStateView()
              else if (memberState is! DataLoaded)
                const Center(child: CircularProgressIndicator()),

            const SizedBox(height: AppSizes.spacing16),
          ],
        );
      },
    );
  }

  Widget _remindersView(
    BuildContext context,
    EventFormState state,
    EventFormCubit cubit,
  ) {
    final isRu = context.locale.languageCode == 'ru';

    return TitleBlock(
      titleKey: LocaleKeys.remind_me,
      child: ReminderDropdown(
        selectedReminders: state.reminders,
        isRussian: isRu,
        noReminderKey: LocaleKeys.no_reminder,
        onToggled: cubit.reminderToggled,
        onNoReminderSelected: cubit.clearReminders,
      ),
    );
  }

  Widget _assignToMeView(
    BuildContext context,
    bool isTrue,
    ValueChanged<bool> onChanged, {
    required bool hasMembers,
  }) {
    return Row(
      children: [
        AvatarCard(
          theme: null,
          avatar: context.read<UserCubit>().state?.avatar ?? Avatar.none,
          size: AvatarSize.small,
          disabled: !isTrue,
        ),
        const SizedBox(width: AppSizes.spacing8),
        Expanded(
          child: BaseText(
            LocaleKeys.assign_to_me,
            color: isTrue
                ? context.colors.purple
                : context.colors.labelSecondary,
            fontWeight: TypographyConst.wSemiBold,
          ),
        ),
        const SizedBox(width: AppSizes.spacing8),
        IgnorePointer(
          ignoring: !hasMembers && isTrue,
          child: Switcher(
            initialValue: isTrue,
            onChanged: (value) => onChanged(value),
          ),
        ),
      ],
    );
  }
}
