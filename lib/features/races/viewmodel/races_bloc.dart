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
    on<RacesTypeChanged>(_onTypeChanged);
    on<RacesSearchChanged>(_onSearchChanged);
    on<RacesFilterChanged>(_onFilterChanged);
    on<RaceDetailRequested>(_onDetailRequested);
    on<RaceDetailResultsLoadMoreRequested>(_onDetailResultsLoadMore);
    on<RaceResultSearchChanged>(_onResultSearchChanged);
    on<RaceResultSearchLoadMoreRequested>(_onResultSearchLoadMore);
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
    final result = await _repository.getRaces(
      page: 1,
      seasonYear: _nullable(state.seasonYearFilter),
      stationName: _nullable(state.stationNameFilter),
    );
    result.fold(
      (f) => emit(
          state.copyWith(status: RacesStatus.error, errorMessage: f.message)),
      (page) => emit(state.copyWith(
        status: RacesStatus.loaded,
        races: page.races,
        currentPage: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onTypeChanged(
    RacesTypeChanged event,
    Emitter<RacesState> emit,
  ) async {
    emit(state.copyWith(
      raceType: event.raceType,
      // Clear all filter fields on type switch
      countryFilter: '',
      clubFilter: '',
      seasonYearFilter: '',
      pointNameFilter: '',
      stationNameFilter: '',
      hobbyistNameFilter: '',
      rankFilter: '',
      birdNumberFilter: '',
      status: RacesStatus.loading,
      clearError: true,
      currentPage: 1,
      hasMore: false,
      loadingMore: false,
    ));
    final result = await _repository.getRaces(page: 1);
    result.fold(
      (f) => emit(
          state.copyWith(status: RacesStatus.error, errorMessage: f.message)),
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
    final result = await _repository.getRaces(
      page: nextPage,
      seasonYear: _nullable(state.seasonYearFilter),
      stationName: _nullable(state.stationNameFilter),
    );
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
      add(const RacesFilterChanged());
      return;
    }
    emit(state.copyWith(
        status: RacesStatus.loading, searchQuery: query, clearError: true));
    final result = await _repository.searchResults(q: query, page: 1);
    result.fold(
      (f) => emit(
          state.copyWith(status: RacesStatus.error, errorMessage: f.message)),
      (results) => emit(state.copyWith(
        status: RacesStatus.searchResults,
        globalSearchResults: results.results,
        resultSearchHasMore: results.hasMore,
        resultSearchCurrentPage: 1,
        resultSearchLoadingMore: false,
      )),
    );
  }

  Future<void> _onFilterChanged(
    RacesFilterChanged event,
    Emitter<RacesState> emit,
  ) async {
    emit(state.copyWith(
      status: RacesStatus.loading,
      // Club filters
      countryFilter: event.country,
      clubFilter: event.club,
      seasonYearFilter: event.seasonYear,
      // OLR filters
      pointNameFilter: event.pointName,
      stationNameFilter: event.stationName,
      hobbyistNameFilter: event.hobbyistName,
      rankFilter: event.rank,
      birdNumberFilter: event.birdNumber,
      searchQuery: '',
      currentPage: 1,
      hasMore: false,
      loadingMore: false,
      clearError: true,
    ));
    // Pass only the fields the backend currently supports
    final result = await _repository.getRaces(
      page: 1,
      seasonYear: _nullable(event.seasonYear),
      stationName: _nullable(event.stationName),
    );
    result.fold(
      (f) => emit(
          state.copyWith(status: RacesStatus.error, errorMessage: f.message)),
      (page) => emit(state.copyWith(
        status: RacesStatus.loaded,
        races: page.races,
        currentPage: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onDetailRequested(
    RaceDetailRequested event,
    Emitter<RacesState> emit,
  ) async {
    emit(state.copyWith(
      detailStatus: RacesDetailStatus.loading,
      clearDetailError: true,
      detailResults: const [],
      detailResultsHasMore: false,
      detailResultsCurrentPage: 1,
      detailResultsLoadingMore: false,
    ));
    final result = await _repository.getRaceDetail(event.raceId);
    final resultsPage = await _repository.getRaceResults(event.raceId, page: 1);
    result.fold(
      (f) => emit(state.copyWith(
          detailStatus: RacesDetailStatus.error,
          detailErrorMessage: f.message)),
      (race) {
        final page = resultsPage.fold(
          (_) => RaceResultPage(results: race.results, hasMore: false),
          (p) => p,
        );
        emit(state.copyWith(
          detailStatus: RacesDetailStatus.loaded,
          selectedRace: race,
          detailResults: page.results,
          detailResultsHasMore: page.hasMore,
          detailResultsCurrentPage: 1,
        ));
      },
    );
  }

  Future<void> _onDetailResultsLoadMore(
    RaceDetailResultsLoadMoreRequested event,
    Emitter<RacesState> emit,
  ) async {
    if (!state.detailResultsHasMore || state.detailResultsLoadingMore) return;
    final nextPage = state.detailResultsCurrentPage + 1;
    emit(state.copyWith(detailResultsLoadingMore: true));
    final result =
        await _repository.getRaceResults(event.raceId, page: nextPage);
    result.fold(
      (f) => emit(state.copyWith(detailResultsLoadingMore: false)),
      (page) => emit(state.copyWith(
        detailResults: [...state.detailResults, ...page.results],
        detailResultsHasMore: page.hasMore,
        detailResultsCurrentPage: nextPage,
        detailResultsLoadingMore: false,
      )),
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
        status: RacesStatus.loaded,
        globalSearchResults: [],
        resultSearchHasMore: false,
        resultSearchCurrentPage: 1,
        resultSearchLoadingMore: false,
      ));
      return;
    }
    final result = await _repository.searchResults(q: query, page: 1);
    result.fold(
      (f) => emit(
          state.copyWith(status: RacesStatus.error, errorMessage: f.message)),
      (results) => emit(state.copyWith(
        status: RacesStatus.searchResults,
        globalSearchResults: results.results,
        resultSearchHasMore: results.hasMore,
        resultSearchCurrentPage: 1,
        resultSearchLoadingMore: false,
      )),
    );
  }

  Future<void> _onResultSearchLoadMore(
    RaceResultSearchLoadMoreRequested event,
    Emitter<RacesState> emit,
  ) async {
    if (!state.resultSearchHasMore || state.resultSearchLoadingMore) return;
    final nextPage = state.resultSearchCurrentPage + 1;
    emit(state.copyWith(resultSearchLoadingMore: true));
    final result = await _repository.searchResults(
      q: state.resultSearchQuery.isNotEmpty
          ? state.resultSearchQuery
          : state.searchQuery,
      page: nextPage,
    );
    result.fold(
      (f) => emit(state.copyWith(resultSearchLoadingMore: false)),
      (page) => emit(state.copyWith(
        globalSearchResults: [...state.globalSearchResults, ...page.results],
        resultSearchHasMore: page.hasMore,
        resultSearchCurrentPage: nextPage,
        resultSearchLoadingMore: false,
      )),
    );
  }

  String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
