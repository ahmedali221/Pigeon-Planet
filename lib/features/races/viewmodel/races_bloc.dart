import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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
    on<RacesFilterSearchRequested>(_onFilterSearch);
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
      status: RacesStatus.initial,
      globalSearchResults: [],
      clearError: true,
    ));
  }

  Future<void> _onTypeChanged(
    RacesTypeChanged event,
    Emitter<RacesState> emit,
  ) async {
    emit(state.copyWith(
      raceType: event.raceType,
      status: RacesStatus.initial,
      globalSearchResults: [],
      countryFilter: '',
      clubFilter: '',
      seasonYearFilter: '',
      pointNameFilter: '',
      stationNameFilter: '',
      hobbyistNameFilter: '',
      rankFilter: '',
      birdNumberFilter: '',
      resultSearchCurrentPage: 1,
      resultSearchHasMore: false,
      resultSearchLoadingMore: false,
      clearError: true,
    ));
  }

  Future<void> _onFilterSearch(
    RacesFilterSearchRequested event,
    Emitter<RacesState> emit,
  ) async {
    emit(state.copyWith(
      status: RacesStatus.loading,
      clearError: true,
      countryFilter: event.country,
      clubFilter: event.clubName,
      seasonYearFilter: event.seasonYear,
      stationNameFilter: event.stationName,
      hobbyistNameFilter: event.hobbyistName,
      pointNameFilter: event.pointName,
      rankFilter: event.rank,
      birdNumberFilter: event.birdNumber,
      globalSearchResults: [],
      resultSearchCurrentPage: 1,
      resultSearchHasMore: false,
      resultSearchLoadingMore: false,
    ));
    // TODO: remove demo block before production
    if (kDebugMode) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final demo = state.raceType == RaceType.olr
          ? _demoOlrResults
          : _demoClubResults;
      emit(state.copyWith(
        status: RacesStatus.loaded,
        globalSearchResults: demo,
        resultSearchHasMore: false,
        resultSearchCurrentPage: 1,
      ));
      return;
    }

    final result = await _repository.searchResults(
      birdRingNumber: _nullable(event.birdNumber),
      clubName: _nullable(event.clubName),
      country: _nullable(event.country),
      seasonYear: _nullable(event.seasonYear),
      stationName: _nullable(event.stationName),
      rank: _nullable(event.rank),
      pointName: _nullable(event.pointName),
      hobbyistName: _nullable(event.hobbyistName),
      page: 1,
    );
    result.fold(
      (f) => emit(
          state.copyWith(status: RacesStatus.error, errorMessage: f.message)),
      (page) => emit(state.copyWith(
        status: RacesStatus.loaded,
        globalSearchResults: page.results,
        resultSearchHasMore: page.hasMore,
        resultSearchCurrentPage: 1,
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
      birdRingNumber: _nullable(state.birdNumberFilter),
      clubName: _nullable(state.clubFilter),
      country: _nullable(state.countryFilter),
      seasonYear: _nullable(state.seasonYearFilter),
      stationName: _nullable(state.stationNameFilter),
      rank: _nullable(state.rankFilter),
      pointName: _nullable(state.pointNameFilter),
      hobbyistName: _nullable(state.hobbyistNameFilter),
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

// Demo results — remove before production

final _demoClubResults = <RaceResultModel>[
  RaceResultModel(
    id: 1, rank: 2, competitorName: 'اسلام مدين',
    birdRingNumber: 'Q25 mfss-8072',
    distanceKm: 397.811, speed: 1058.15, arrivalDatetime: '',
    basketNumber: 28, country: 'مصر', clubName: 'القليوبية',
    raceSeasonYear: 2024, raceStationName: 'مربي مطروح_2025',
    points: 137.20, totalBirds: 390,
    resultLines1: '3:33:33,3', resultLines2: '3:33:33,3',
  ),
  RaceResultModel(
    id: 2, rank: 2, competitorName: 'كريم عادل',
    birdRingNumber: 'GZ24 EZAZ-322',
    distanceKm: 530.511, speed: 95.625, arrivalDatetime: '',
    basketNumber: 16, country: 'مصر', clubName: 'القليوبية',
    raceSeasonYear: 2024, raceStationName: 'سيدي براني_2025',
    points: 156.80, totalBirds: 314,
    resultLines1: '3:33:33,3', resultLines2: '3:33:33,3',
  ),
  RaceResultModel(
    id: 3, rank: 2, competitorName: 'رشاد العباسي',
    birdRingNumber: 'Q25 HDED-2304',
    distanceKm: 483.082, speed: 1449.68, arrivalDatetime: '',
    basketNumber: 34, country: 'مصر', clubName: 'القليوبية',
    raceSeasonYear: 2024, raceStationName: 'زويه حماس_300_2025',
    points: 147.00, totalBirds: 300,
    resultLines1: '3:33:33,3', resultLines2: '3:33:33,3',
  ),
  RaceResultModel(
    id: 4, rank: 2, competitorName: 'رامي & طارق زايد',
    birdRingNumber: 'Q25 EZAZ-3709',
    distanceKm: 336.605, speed: 1521.61, arrivalDatetime: '',
    basketNumber: 24, country: 'مصر', clubName: 'القليوبية',
    raceSeasonYear: 2024, raceStationName: 'راس الحكمه_2025',
    points: 127.40, totalBirds: 600,
    resultLines1: '3:33:33,3', resultLines2: '3:33:33,3',
  ),
  RaceResultModel(
    id: 5, rank: 2, competitorName: 'اشرف محمد',
    birdRingNumber: 'Q23 azazz7050',
    distanceKm: 228.202, speed: 1300.17, arrivalDatetime: '',
    basketNumber: 143, country: 'مصر', clubName: 'القليوبية',
    raceSeasonYear: 2024, raceStationName: 'العالمين_2025',
    points: 107.80, totalBirds: 950,
  ),
  RaceResultModel(
    id: 6, rank: 2, competitorName: 'سلمان سعد',
    birdRingNumber: 'Q20 EZAZ-083',
    distanceKm: 592.867, speed: 1436.38, arrivalDatetime: '',
    basketNumber: 7, country: 'مصر', clubName: 'القليوبية',
    raceSeasonYear: 2024, raceStationName: 'السلوم_2025',
    points: 166.60, totalBirds: 170,
    resultLines1: '31:30:47,9', resultLines2: '25:12:05,6',
  ),
];

final _demoOlrResults = <RaceResultModel>[
  RaceResultModel(
    id: 101, rank: 1, competitorName: 'محمد أحمد',
    birdRingNumber: 'Q25 OLR-1001',
    distanceKm: 512.40, speed: 1320.55,
    arrivalDatetime: '2025-03-15 14:32:10',
    basketNumber: 5, raceSeasonYear: 2024,
    raceStationName: 'الإسكندرية_2025',
    pointName: 'نقطة القاهرة',
    timeDifference: '00:12:45', arrivalsCount: 48,
  ),
  RaceResultModel(
    id: 102, rank: 2, competitorName: 'خالد محمود',
    birdRingNumber: 'Q25 OLR-2034',
    distanceKm: 488.70, speed: 1180.30,
    arrivalDatetime: '2025-03-15 14:45:22',
    basketNumber: 12, raceSeasonYear: 2024,
    raceStationName: 'الإسكندرية_2025',
    pointName: 'نقطة القاهرة',
    timeDifference: '00:25:57', arrivalsCount: 48,
  ),
  RaceResultModel(
    id: 103, rank: 3, competitorName: 'سامي حسن',
    birdRingNumber: 'GZ24 OLR-5512',
    distanceKm: 530.10, speed: 1095.80,
    arrivalDatetime: '2025-03-15 15:01:05',
    basketNumber: 9, raceSeasonYear: 2024,
    raceStationName: 'مطروح_2025',
    pointName: 'نقطة الجيزة',
    timeDifference: '00:41:40', arrivalsCount: 31,
  ),
  RaceResultModel(
    id: 104, rank: 4, competitorName: 'عمر السيد',
    birdRingNumber: 'Q23 OLR-8801',
    distanceKm: 475.30, speed: 980.45,
    arrivalDatetime: '2025-03-15 15:18:33',
    basketNumber: 22, raceSeasonYear: 2024,
    raceStationName: 'مطروح_2025',
    pointName: 'نقطة الجيزة',
    timeDifference: '00:58:18', arrivalsCount: 31,
  ),
  RaceResultModel(
    id: 105, rank: 5, competitorName: 'يوسف علي',
    birdRingNumber: 'Q25 OLR-3390',
    distanceKm: 550.60, speed: 870.20,
    arrivalDatetime: '2025-03-15 15:44:51',
    basketNumber: 37, raceSeasonYear: 2024,
    raceStationName: 'السلوم_2025',
    pointName: 'نقطة الإسكندرية',
    timeDifference: '01:24:36', arrivalsCount: 19,
  ),
];
