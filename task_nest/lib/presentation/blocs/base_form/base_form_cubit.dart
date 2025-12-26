import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/presentation/blocs/base_form/base_form_state.dart';

abstract class FormCubit<S extends FormState> extends Cubit<S> {
  FormCubit(super.initialState);

  ///
  /// STATES
  ///

  void emitLoading() => emit(state.copyWith(isSaving: true) as S);

  void emitError(String? error) => emit(
    state.copyWith(isSaving: false, hasError: true, errorMessage: error) as S,
  );

  void emitComplete() => emit(
    state.copyWith(isSaving: false, hasError: false, completed: true) as S,
  );

  ///
  /// EXECUTOR
  ///

  void processUseCaseResult<T>(
    Either<Failure, T> result, {
    required Function(T) onSuccess,
  }) {
    result.fold(
      (failure) => emitError(failure.message),
      (success) => onSuccess(success),
    );
  }
}
