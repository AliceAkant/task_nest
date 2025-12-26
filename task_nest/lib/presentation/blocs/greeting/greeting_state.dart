import 'package:equatable/equatable.dart';
import 'package:task_nest/domain/enums/avatar.dart';

class GreetingState extends Equatable {
  final String name;
  final Avatar avatar;
  final bool validationMode;
  final bool isValid;
  final bool isSaving;
  final bool? completed;

  const GreetingState({
    required this.name,
    required this.avatar,
    required this.validationMode,
    required this.isValid,
    required this.isSaving,

    this.completed,
  });

  factory GreetingState.initial() {
    return GreetingState(
      name: '',
      avatar: Avatar.values.elementAt(1),
      validationMode: false,
      isValid: false,
      isSaving: false,
      completed: false,
    );
  }

  GreetingState copyWith({
    String? name,
    Avatar? avatar,
    bool? validationMode,
    bool? isValid,
    bool? isSaving,
    bool? completed,
  }) {
    return GreetingState(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      validationMode: validationMode ?? this.validationMode,
      isValid: isValid ?? this.isValid,
      isSaving: isSaving ?? this.isSaving,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [
    name,
    avatar,
    validationMode,
    isValid,
    isSaving,
    completed,
  ];
}
