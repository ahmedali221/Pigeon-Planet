import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/referrals_repository.dart';
import 'referrals_event.dart';
import 'referrals_state.dart';

export 'referrals_event.dart';
export 'referrals_state.dart';

class ReferralsBloc extends Bloc<ReferralsEvent, ReferralsState> {
  final ReferralsRepository _repository;

  ReferralsBloc({required ReferralsRepository repository})
      : _repository = repository,
        super(const ReferralsState()) {
    on<ReferralsCodeRequested>(_onCodeRequested);
    on<ReferralsRedeemRequested>(_onRedeem);
  }

  Future<void> _onCodeRequested(
    ReferralsCodeRequested event,
    Emitter<ReferralsState> emit,
  ) async {
    emit(state.copyWith(status: ReferralsStatus.loading, clearError: true));
    final result = await _repository.createOrGetCode();
    result.fold(
      (f) => emit(state.copyWith(
        status: ReferralsStatus.error,
        errorMessage: f.message,
      )),
      (code) => emit(state.copyWith(
        status: ReferralsStatus.loaded,
        myCode: code,
      )),
    );
  }

  Future<void> _onRedeem(
    ReferralsRedeemRequested event,
    Emitter<ReferralsState> emit,
  ) async {
    emit(state.copyWith(
      status: ReferralsStatus.redeeming,
      clearError: true,
      resetActions: true,
    ));
    final result = await _repository.redeemCode(event.code);
    result.fold(
      (f) => emit(state.copyWith(
        status: ReferralsStatus.loaded,
        errorMessage: f.message,
      )),
      (_) => emit(state.copyWith(
        status: ReferralsStatus.loaded,
        redeemSuccess: true,
      )),
    );
  }
}
