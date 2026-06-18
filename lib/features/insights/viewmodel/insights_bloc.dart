import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/insights_repository.dart';
import '../model/seller_insights_model.dart';

part 'insights_event.dart';
part 'insights_state.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final InsightsRepository _repository;

  InsightsBloc({required InsightsRepository repository})
      : _repository = repository,
        super(const InsightsState()) {
    on<InsightsStarted>(_onLoad);
    on<InsightsRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(
    InsightsEvent event,
    Emitter<InsightsState> emit,
  ) async {
    emit(InsightsState(
      status: InsightsStatus.loading,
      insights: state.insights,
    ));
    final result = await _repository.getSellerInsights();
    result.fold(
      (failure) => emit(InsightsState(
        status: InsightsStatus.error,
        insights: state.insights,
        errorMessage: failure.message,
      )),
      (data) => emit(InsightsState(
        status: InsightsStatus.loaded,
        insights: data,
      )),
    );
  }
}
