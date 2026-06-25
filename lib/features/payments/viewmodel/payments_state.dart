part of 'payments_bloc.dart';

enum PaymentsStatus { initial, loading, loaded, error }

class PaymentsState extends Equatable {
  final PaymentsStatus status;
  final List<PaymentRequestModel> requests;
  final String? errorMessage;
  final bool isCreating;
  final String? createError;
  final bool reusedExistingRequest;
  final bool isActing; // approve / reject / note update
  final String? actionError;

  const PaymentsState({
    this.status = PaymentsStatus.initial,
    this.requests = const [],
    this.errorMessage,
    this.isCreating = false,
    this.createError,
    this.reusedExistingRequest = false,
    this.isActing = false,
    this.actionError,
  });

  PaymentsState copyWith({
    PaymentsStatus? status,
    List<PaymentRequestModel>? requests,
    String? errorMessage,
    bool? isCreating,
    String? createError,
    bool? reusedExistingRequest,
    bool? isActing,
    String? actionError,
  }) =>
      PaymentsState(
        status: status ?? this.status,
        requests: requests ?? this.requests,
        errorMessage: errorMessage ?? this.errorMessage,
        isCreating: isCreating ?? this.isCreating,
        createError: createError ?? this.createError,
        reusedExistingRequest:
            reusedExistingRequest ?? this.reusedExistingRequest,
        isActing: isActing ?? this.isActing,
        actionError: actionError ?? this.actionError,
      );

  @override
  List<Object?> get props => [
        status,
        requests,
        errorMessage,
        isCreating,
        createError,
        reusedExistingRequest,
        isActing,
        actionError,
      ];
}
