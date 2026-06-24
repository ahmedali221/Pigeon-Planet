import 'package:equatable/equatable.dart';

import '../model/referral_model.dart';

enum ReferralsStatus { initial, loading, loaded, redeeming, error }

class ReferralsState extends Equatable {
  final ReferralsStatus status;
  final ReferralCodeModel? myCode;
  final String? errorMessage;
  final bool redeemSuccess;

  const ReferralsState({
    this.status = ReferralsStatus.initial,
    this.myCode,
    this.errorMessage,
    this.redeemSuccess = false,
  });

  ReferralsState copyWith({
    ReferralsStatus? status,
    ReferralCodeModel? myCode,
    String? errorMessage,
    bool? redeemSuccess,
    bool clearError = false,
    bool resetActions = false,
  }) =>
      ReferralsState(
        status: status ?? this.status,
        myCode: myCode ?? this.myCode,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        redeemSuccess:
            resetActions ? false : redeemSuccess ?? this.redeemSuccess,
      );

  @override
  List<Object?> get props =>
      [status, myCode, errorMessage, redeemSuccess];
}
