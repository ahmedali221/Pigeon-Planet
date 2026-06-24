part of 'races_bloc.dart';

enum RacesStatus { initial, loading, loaded, searchResults, error }

enum RacesDetailStatus { initial, loading, loaded, error }

class RacesState extends Equatable {
  final RacesStatus status;
  final RacesDetailStatus detailStatus;
  final List<RaceModel> races;
  final List<RaceResultModel> globalSearchResults;
  final bool resultSearchHasMore;
  final int resultSearchCurrentPage;
  final bool resultSearchLoadingMore;
  final RaceModel? selectedRace;
  final List<RaceResultModel> detailResults;
  final bool detailResultsHasMore;
  final int detailResultsCurrentPage;
  final bool detailResultsLoadingMore;
  final String searchQuery;
  final String resultSearchQuery;
  final String seasonYearFilter;
  final String stationNameFilter;
  final String? errorMessage;
  final String? detailErrorMessage;
  final int currentPage;
  final bool hasMore;
  final bool loadingMore;

  const RacesState({
    this.status = RacesStatus.initial,
    this.detailStatus = RacesDetailStatus.initial,
    this.races = const [],
    this.globalSearchResults = const [],
    this.resultSearchHasMore = false,
    this.resultSearchCurrentPage = 1,
    this.resultSearchLoadingMore = false,
    this.selectedRace,
    this.detailResults = const [],
    this.detailResultsHasMore = false,
    this.detailResultsCurrentPage = 1,
    this.detailResultsLoadingMore = false,
    this.searchQuery = '',
    this.resultSearchQuery = '',
    this.seasonYearFilter = '',
    this.stationNameFilter = '',
    this.errorMessage,
    this.detailErrorMessage,
    this.currentPage = 1,
    this.hasMore = false,
    this.loadingMore = false,
  });

  RacesState copyWith({
    RacesStatus? status,
    RacesDetailStatus? detailStatus,
    List<RaceModel>? races,
    List<RaceResultModel>? globalSearchResults,
    bool? resultSearchHasMore,
    int? resultSearchCurrentPage,
    bool? resultSearchLoadingMore,
    RaceModel? selectedRace,
    List<RaceResultModel>? detailResults,
    bool? detailResultsHasMore,
    int? detailResultsCurrentPage,
    bool? detailResultsLoadingMore,
    String? searchQuery,
    String? resultSearchQuery,
    String? seasonYearFilter,
    String? stationNameFilter,
    String? errorMessage,
    String? detailErrorMessage,
    bool clearError = false,
    bool clearDetailError = false,
    bool clearSelectedRace = false,
    int? currentPage,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return RacesState(
      status: status ?? this.status,
      detailStatus: detailStatus ?? this.detailStatus,
      races: races ?? this.races,
      globalSearchResults: globalSearchResults ?? this.globalSearchResults,
      resultSearchHasMore: resultSearchHasMore ?? this.resultSearchHasMore,
      resultSearchCurrentPage:
          resultSearchCurrentPage ?? this.resultSearchCurrentPage,
      resultSearchLoadingMore:
          resultSearchLoadingMore ?? this.resultSearchLoadingMore,
      selectedRace: clearSelectedRace ? null : (selectedRace ?? this.selectedRace),
      detailResults: detailResults ?? this.detailResults,
      detailResultsHasMore: detailResultsHasMore ?? this.detailResultsHasMore,
      detailResultsCurrentPage:
          detailResultsCurrentPage ?? this.detailResultsCurrentPage,
      detailResultsLoadingMore:
          detailResultsLoadingMore ?? this.detailResultsLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      resultSearchQuery: resultSearchQuery ?? this.resultSearchQuery,
      seasonYearFilter: seasonYearFilter ?? this.seasonYearFilter,
      stationNameFilter: stationNameFilter ?? this.stationNameFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      detailErrorMessage: clearDetailError
          ? null
          : (detailErrorMessage ?? this.detailErrorMessage),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  @override
  List<Object?> get props => [
        status,
        detailStatus,
        races,
        globalSearchResults,
        resultSearchHasMore,
        resultSearchCurrentPage,
        resultSearchLoadingMore,
        selectedRace,
        detailResults,
        detailResultsHasMore,
        detailResultsCurrentPage,
        detailResultsLoadingMore,
        searchQuery,
        resultSearchQuery,
        seasonYearFilter,
        stationNameFilter,
        errorMessage,
        detailErrorMessage,
        currentPage,
        hasMore,
        loadingMore,
      ];
}
