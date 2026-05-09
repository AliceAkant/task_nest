import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/domain/usecases/app_preferences_use_cases.dart';
import 'package:task_nest/infrastructure/di/injection.dart';
import 'package:task_nest/infrastructure/localization/localization_model.dart';

class LocalizationCubit extends Cubit<LocalizationModel> {
  final SetLocaleKeyUseCase _setLocaleKey;

  LocalizationCubit(super.initialState)
    : _setLocaleKey = DI.container<SetLocaleKeyUseCase>();

  void changeLocale(LocalizationModel localization) {
    emit(localization);
    _setLocaleKey.call(localization.localeKey);
  }
}
