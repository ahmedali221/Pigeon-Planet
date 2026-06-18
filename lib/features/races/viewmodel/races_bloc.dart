import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/race_model.dart';
import '../model/races_repository.dart';

part 'races_event.dart';
part 'races_state.dart';

class RacesBloc extends Bloc<RacesEvent, RacesState> {
  final RacesRepository _repository;

  RacesBloc({required RacesRepository repository})
      : _repository = repository,
        super(const RacesState()) {
    on<RacesStarted>(_onStarted);
    on<RacesRefreshRequested>(_onStarted);
    on<RacesSearchChanged>(_onSearchChanged);
    on<RaceDetailRequested>(_onDetailRequested);
    on<RaceResultSearchChanged>(_onResultSearchChanged);
    on<RacesLoadMoreRequested>(_onLoadMore);
  }

  Future<void> _onStarted(
    RacesEvent event,
    Emitter<RacesState> emit,
  ) async {
    emit(state.copyWith(
      status: RacesStatus.loading,
      clearError: true,
      currentPage: 1,
      hasMore: false,
      loadingMore: false,
    ));
    final result = await _repository.getRaces(page: 1);
    result.fold(
      (f) => emit(state.copyWith(
          status: RacesStatus.error, errorMessage: f.message)),
      (page) => emit(state.copyWith(
        status: RacesStatus.loaded,
        races: page.races,
        currentPage: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onLoadMore(
    RacesLoadMoreRequested event,
    Emitter<RacesState> emit,
  ) async {
    if (!state.hasMore || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    final nextPage = state.currentPage + 1;
    final result = await _repository.getRaces(page: nextPage);
    result.fold(
      (f) => emit(state.copyWith(loadingMore: false)),
      (page) => emit(state.copyWith(
        races: [...state.races, ...page.races],
        currentPage: nextPage,
        hasMore: page.hasMore,
        loadingMore: false,
      )),
    );
  }

  Future<void> _onSearchChanged(
    RacesSearchChanged event,
    Emitter<RacesState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      add(const RacesStarted());
      return;
    }
    emit(state.copyWith(
        status: RacesStatus.loading, searchQuery: query, clearError: true));
    final result = await _repository.searchResults(q: query);
    result.fold(
      (f) => emit(state.copyWith(
          status: RacesStatus.error, errorMessage: f.message)),
      (results) => emit(state.copyWith(
          status: RacesStatus.searchResults, globalSearchResults: results)),
    );
  }

  Future<void> _onDetailRequested(
    RaceDetailRequested event,
    Emitter<RacesState> emit,
  ) async {
    emit(state.copyWith(
        detailStatus: RacesDetailStatus.loading, clearDetailError: true));
    final result = await _repository.getRaceDetail(event.raceId);
    result.fold(
      (f) => emit(state.copyWith(
          detailStatus: RacesDetailStatus.error,
          detailErrorMessage: f.message)),
      (race) => emit(state.copyWith(
          detailStatus: RacesDetailStatus.loaded, selectedRace: race)),
    );
  }

  Future<void> _onResultSearchChanged(
    RaceResultSearchChanged event,
    Emitter<RacesState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(
        resultSearchQuery: query,
        status: query.isEmpty ? RacesStatus.loaded : RacesStatus.loading,
        clearError: true));
    if (query.isEmpty) {
      emit(state.copyWith(
          status: RacesStatus.loaded, globalSearchResults: []));
      return;
    }
    final result = await _repository.searchResults(q: query);
    result.fold(
      (f) => emit(state.copyWith(
          status: RacesStatus.error, errorMessage: f.message)),
      (results) => emit(state.copyWith(
          status: RacesStatus.searchResults, globalSearchResults: results)),
    );
  }
}
