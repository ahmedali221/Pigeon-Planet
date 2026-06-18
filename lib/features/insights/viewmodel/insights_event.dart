part of 'insights_bloc.dart';

abstract class InsightsEvent extends Equatable {
  const InsightsEvent();

  @override
  List<Object?> get props => [];
}

class InsightsStarted extends InsightsEvent {
  const InsightsStarted();
}

class InsightsRefreshRequested extends InsightsEvent {
  const InsightsRefreshRequested();
}
