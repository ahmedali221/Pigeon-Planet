part of 'transfers_bloc.dart';

enum TransfersStatus { initial, loading, loaded, error }

class TransfersState extends Equatable {
  final TransfersStatus status;
  final List<OwnershipTransferModel> transfers;
  final String? errorMessage;
  final bool isCreating;
  final bool created;
  final String? createError;
  final List<SellerModel> sellerSearchResults;
  final bool isSearching;

  const TransfersState({
    this.status = TransfersStatus.initial,
    this.transfers = const [],
    this.errorMessage,
    this.isCreating = false,
    this.created = false,
    this.createError,
    this.sellerSearchResults = const [],
    this.isSearching = false,
  });

  TransfersState copyWith({
    TransfersStatus? status,
    List<OwnershipTransferModel>? transfers,
    String? errorMessage,
    bool? isCreating,
    bool? created,
    String? createError,
    List<SellerModel>? sellerSearchResults,
    bool? isSearching,
    bool clearError = false,
    bool clearCreateError = false,
  }) =>
      TransfersState(
        status: status ?? this.status,
        transfers: transfers ?? this.transfers,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        isCreating: isCreating ?? this.isCreating,
        created: created ?? this.created,
        createError:
            clearCreateError ? null : (createError ?? this.createError),
        sellerSearchResults: sellerSearchResults ?? this.sellerSearchResults,
        isSearching: isSearching ?? this.isSearching,
      );

  @override
  List<Object?> get props => [
        status,
        transfers,
        errorMessage,
        isCreating,
        created,
        createError,
        sellerSearchResults,
        isSearching,
      ];
}
