import 'package:equatable/equatable.dart';

abstract class ReferralsEvent extends Equatable {
  const ReferralsEvent();

  @override
  List<Object?> get props => [];
}

class ReferralsCodeRequested extends ReferralsEvent {
  const ReferralsCodeRequested();
}

class ReferralsRedeemRequested extends ReferralsEvent {
  final String code;

  const ReferralsRedeemRequested(this.code);

  @override
  List<Object?> get props => [code];
}
