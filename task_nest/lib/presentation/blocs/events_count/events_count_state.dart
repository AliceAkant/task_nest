part of 'events_count_cubit.dart';

sealed class EventsCountState extends Equatable {
  const EventsCountState();

  @override
  List<Object?> get props => [];
}

final class EventsCountInitial extends EventsCountState {}

final class Loading extends EventsCountState {}

final class DataLoaded extends EventsCountState {
  final Map<DateTime, int> countsMap;

  const DataLoaded(this.countsMap);

  @override
  List<Object> get props => [countsMap];
}

final class LoadError extends EventsCountState {
  const LoadError();

  @override
  List<Object> get props => [];
}
