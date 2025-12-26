import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/infrastructure/localization/localization_model.dart';
import 'package:task_nest/infrastructure/storage/sp/shared_preferences_helper.dart';

class LocalizationCubit extends Cubit<LocalizationModel> {
  LocalizationCubit(super.initialState);

  void changeLocale(LocalizationModel localization) {
    emit(localization);
    SharedPreferencesHelper.setLocale(localization.localeKey);
  }
}
