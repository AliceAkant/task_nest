part of 'members_cubit.dart';

sealed class MembersState extends Equatable {
  const MembersState();

  @override
  List<Object?> get props => [];
}

final class MembersInitial extends MembersState {}

final class Loading extends MembersState {}

final class DataLoaded extends MembersState {
  final List<Member> members;

  const DataLoaded(this.members);

  @override
  List<Object> get props => [members];
}

final class LoadError extends MembersState {
  const LoadError();

  @override
  List<Object> get props => [];
}
