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

class RacesTypeChanged extends RacesEvent {
  final RaceType raceType;
  const RacesTypeChanged(this.raceType);

  @override
  List<Object?> get props => [raceType];
}

class RacesSearchChanged extends RacesEvent {
  final String query;
  const RacesSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class RacesFilterChanged extends RacesEvent {
  // Club filters
  final String country;
  final String club;
  final String seasonYear;
  // OLR filters
  final String pointName;
  final String stationName;
  final String hobbyistName;
  final String rank;
  final String birdNumber;

  const RacesFilterChanged({
    this.country = '',
    this.club = '',
    this.seasonYear = '',
    this.pointName = '',
    this.stationName = '',
    this.hobbyistName = '',
    this.rank = '',
    this.birdNumber = '',
  });

  @override
  List<Object?> get props =>
      [country, club, seasonYear, pointName, stationName, hobbyistName, rank, birdNumber];
}

class RaceDetailRequested extends RacesEvent {
  final int raceId;
  const RaceDetailRequested(this.raceId);

  @override
  List<Object?> get props => [raceId];
}

class RaceDetailResultsLoadMoreRequested extends RacesEvent {
  final int raceId;
  const RaceDetailResultsLoadMoreRequested(this.raceId);

  @override
  List<Object?> get props => [raceId];
}

class RaceResultSearchChanged extends RacesEvent {
  final String query;
  const RaceResultSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class RaceResultSearchLoadMoreRequested extends RacesEvent {
  const RaceResultSearchLoadMoreRequested();
}

class RacesLoadMoreRequested extends RacesEvent {
  const RacesLoadMoreRequested();
}
