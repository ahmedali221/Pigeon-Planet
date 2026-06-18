import 'package:equatable/equatable.dart';

abstract class PromotionsEvent extends Equatable {
  const PromotionsEvent();
  @override
  List<Object?> get props => [];
}

class PromotionsStarted extends PromotionsEvent {
  const PromotionsStarted();
}

class PromotionsRefreshed extends PromotionsEvent {
  const PromotionsRefreshed();
}
