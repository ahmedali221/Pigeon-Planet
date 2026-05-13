part of 'home_bloc.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<AuctionModel> activeAuctions;
  final List<AuctionModel> endingSoonAuctions;
  final List<ProductModel> featuredBirds;
  final SellerHomeSummary? sellerSummary;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.activeAuctions = const [],
    this.endingSoonAuctions = const [],
    this.featuredBirds = const [],
    this.sellerSummary,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<AuctionModel>? activeAuctions,
    List<AuctionModel>? endingSoonAuctions,
    List<ProductModel>? featuredBirds,
    SellerHomeSummary? sellerSummary,
    String? errorMessage,
    bool clearError = false,
    bool clearSellerSummary = false,
  }) =>
      HomeState(
        status: status ?? this.status,
        activeAuctions: activeAuctions ?? this.activeAuctions,
        endingSoonAuctions: endingSoonAuctions ?? this.endingSoonAuctions,
        featuredBirds: featuredBirds ?? this.featuredBirds,
        sellerSummary: clearSellerSummary
            ? null
            : (sellerSummary ?? this.sellerSummary),
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [
        status,
        activeAuctions,
        endingSoonAuctions,
        featuredBirds,
        sellerSummary,
        errorMessage,
      ];
}
