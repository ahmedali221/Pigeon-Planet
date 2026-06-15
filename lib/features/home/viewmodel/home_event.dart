part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  final bool isSeller;

  const HomeEvent({this.isSeller = false});

  @override
  List<Object?> get props => [isSeller];
}

class HomeStarted extends HomeEvent {
  const HomeStarted({super.isSeller});
}

class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested({super.isSeller});
}
