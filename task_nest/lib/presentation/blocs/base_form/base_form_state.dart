import 'package:equatable/equatable.dart';

abstract class BaseFormState extends Equatable {
  final bool isSaving;
  final bool hasError;
  final String? errorMessage;
  final bool? completed;

  const BaseFormState({
    required this.isSaving,
    required this.hasError,
    this.errorMessage,
    this.completed,
  });

  BaseFormState copyWith({
    bool? isSaving,
    bool? hasError,
    String? errorMessage,
    bool? completed,
  });

  @override
  List<Object?> get props => [isSaving, hasError, errorMessage, completed];
}
