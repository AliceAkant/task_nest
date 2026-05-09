import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/domain/usecases/events_use_cases.dart';
import 'package:task_nest/infrastructure/di/injection.dart';
import 'package:task_nest/core/extensions/date_time_extension.dart';

part 'events_count_state.dart';

class EventsCountCubit extends Cubit<EventsCountState> {
  final GetEventsCountUseCase _getCountUC;

  EventsCountCubit()
    : _getCountUC = DI.container<GetEventsCountUseCase>(),
      super(EventsCountInitial());

  Future loadData() async {
    emit(Loading());

    final startDate = DateTime.now()
        .subtract(const Duration(days: 365))
        .dateOnly;

    final result = await _getCountUC.call(startDate, 24);

    result.fold(
      (failure) => emit(LoadError()),
      (savedMember) => emit(DataLoaded(savedMember)),
    );
  }
}
