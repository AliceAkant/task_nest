import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/domain/usecases/events/get_events_count_usecase.dart';
import 'package:task_nest/infrastructure/di/injection.dart';
import 'package:task_nest/presentation/extensions/date_time_extension.dart';

part 'events_count_state.dart';

class EventsCountCubit extends Cubit<EventsCountState> {
  final GetEventsCountUseCase _getCountUC;

  EventsCountCubit()
    : _getCountUC = DI.container<GetEventsCountUseCase>(),
      super(EventsCountInitial());

  Future loadData() async {
    emit(Loading());

    final startDate = DateTime.now().dateOnly;

    final result = await _getCountUC.call(startDate, 3);

    result.fold(
      (failure) => emit(LoadError()),
      (savedMember) => emit(DataLoaded(savedMember)),
    );
  }
}
