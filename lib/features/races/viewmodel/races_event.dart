part of 'races_bloc.dart';

abstract class RacesEvent extends Equatable {
  const RacesEvent();

  @override
  List<Object?> get props => [];
}

class RacesStarted extends RacesEvent {
  const RacesStarted();
}

class RacesRefreshRequested extends RacesEvent {
  const RacesRefreshRequested();
}

class RacesSearchChanged extends RacesEvent {
  final String query;
  const RacesSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class RacesFilterChanged extends RacesEvent {
  final String seasonYear;
  final String stationName;

  const RacesFilterChanged({
    required this.seasonYear,
    required this.stationName,
  });

  @override
  List<Object?> get props => [seasonYear, stationName];
}

class RaceDetailRequested extends RacesEvent {
  final int raceId;
  const RaceDetailRequested(this.raceId);

  @override
  List<Object?> get props => [raceId];
}

class RaceResultSearchChanged extends RacesEvent {
  final String query;
  const RaceResultSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class RacesLoadMoreRequested extends RacesEvent {
  const RacesLoadMoreRequested();
}
