part of 'home_bloc.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<AuctionModel> activeAuctions;
  final List<AuctionModel> endingSoonAuctions;
  final List<AuctionModel> comingSoonAuctions;
  final List<BirdSummaryModel> featuredBirds;
  final List<BirdSummaryModel> myBirds;
  final List<SellerModel> sellers;
  final SellerHomeSummary? sellerSummary;
  final CustomerHomeSummary? customerSummary;
  final int unreadNotificationCount;
  final int? pointsBalance;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.activeAuctions = const [],
    this.endingSoonAuctions = const [],
    this.comingSoonAuctions = const [],
    this.featuredBirds = const [],
    this.myBirds = const [],
    this.sellers = const [],
    this.sellerSummary,
    this.customerSummary,
    this.unreadNotificationCount = 0,
    this.pointsBalance,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<AuctionModel>? activeAuctions,
    List<AuctionModel>? endingSoonAuctions,
    List<AuctionModel>? comingSoonAuctions,
    List<BirdSummaryModel>? featuredBirds,
    List<BirdSummaryModel>? myBirds,
    List<SellerModel>? sellers,
    SellerHomeSummary? sellerSummary,
    CustomerHomeSummary? customerSummary,
    int? unreadNotificationCount,
    int? pointsBalance,
    String? errorMessage,
    bool clearError = false,
    bool clearSellerSummary = false,
    bool clearCustomerSummary = false,
  }) =>
      HomeState(
        status: status ?? this.status,
        activeAuctions: activeAuctions ?? this.activeAuctions,
        endingSoonAuctions: endingSoonAuctions ?? this.endingSoonAuctions,
        comingSoonAuctions: comingSoonAuctions ?? this.comingSoonAuctions,
        featuredBirds: featuredBirds ?? this.featuredBirds,
        myBirds: myBirds ?? this.myBirds,
        sellers: sellers ?? this.sellers,
        sellerSummary: clearSellerSummary
            ? null
            : (sellerSummary ?? this.sellerSummary),
        customerSummary: clearCustomerSummary
            ? null
            : (customerSummary ?? this.customerSummary),
        unreadNotificationCount:
            unreadNotificationCount ?? this.unreadNotificationCount,
        pointsBalance: pointsBalance ?? this.pointsBalance,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [
        status,
        activeAuctions,
        endingSoonAuctions,
        comingSoonAuctions,
        featuredBirds,
        myBirds,
        sellers,
        sellerSummary,
        customerSummary,
        unreadNotificationCount,
        pointsBalance,
        errorMessage,
      ];
}
