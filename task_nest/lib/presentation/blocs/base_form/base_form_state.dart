import 'package:equatable/equatable.dart';

abstract class FormState extends Equatable {
  final bool isSaving;
  final bool hasError;
  final String? errorMessage;
  final bool? completed;

  const FormState({
    required this.isSaving,
    required this.hasError,
    this.errorMessage,
    this.completed,
  });

  FormState copyWith({
    bool? isSaving,
    bool? hasError,
    String? errorMessage,
    bool? completed,
  });

  @override
  List<Object?> get props => [isSaving, hasError, errorMessage, completed];
}
