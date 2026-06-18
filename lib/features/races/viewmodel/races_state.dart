part of 'races_bloc.dart';

enum RacesStatus { initial, loading, loaded, searchResults, error }

enum RacesDetailStatus { initial, loading, loaded, error }

class RacesState extends Equatable {
  final RacesStatus status;
  final RacesDetailStatus detailStatus;
  final List<RaceModel> races;
  final List<RaceResultModel> globalSearchResults;
  final RaceModel? selectedRace;
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
    this.selectedRace,
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
    RaceModel? selectedRace,
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
      selectedRace: clearSelectedRace ? null : (selectedRace ?? this.selectedRace),
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
        selectedRace,
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
