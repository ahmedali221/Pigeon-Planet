part of 'home_bloc.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<AuctionModel> activeAuctions;
  final List<AuctionModel> endingSoonAuctions;
  final List<AuctionModel> comingSoonAuctions;
  final List<AuctionModel> myAuctions;
  final List<BirdSummaryModel> featuredBirds;
  final List<BirdSummaryModel> myBirds;
  final List<SellerModel> sellers;
  final List<AnnouncementModel> announcements;
  final SellerHomeSummary? sellerSummary;
  final CustomerHomeSummary? customerSummary;
  final int unreadNotificationCount;
  final int? pointsBalance;
  final String? errorMessage;

  // Per-section loading flags — each section shows a skeleton until its flag is false.
  final bool activeAuctionsLoading;
  final bool endingSoonLoading;
  final bool comingSoonLoading;
  final bool sellersLoading;
  final bool announcementsLoading;
  final bool summaryLoading;
  final bool sellerPrivateLoading;
  final bool featuredBirdsLoading;

  const HomeState({
    this.status = HomeStatus.initial,
    this.activeAuctions = const [],
    this.endingSoonAuctions = const [],
    this.comingSoonAuctions = const [],
    this.myAuctions = const [],
    this.featuredBirds = const [],
    this.myBirds = const [],
    this.sellers = const [],
    this.announcements = const [],
    this.sellerSummary,
    this.customerSummary,
    this.unreadNotificationCount = 0,
    this.pointsBalance,
    this.errorMessage,
    this.activeAuctionsLoading = false,
    this.endingSoonLoading = false,
    this.comingSoonLoading = false,
    this.sellersLoading = false,
    this.announcementsLoading = false,
    this.summaryLoading = false,
    this.sellerPrivateLoading = false,
    this.featuredBirdsLoading = false,
  });

  bool get anyLoading =>
      activeAuctionsLoading ||
      endingSoonLoading ||
      comingSoonLoading ||
      sellersLoading ||
      announcementsLoading ||
      summaryLoading ||
      sellerPrivateLoading;

  HomeState copyWith({
    HomeStatus? status,
    List<AuctionModel>? activeAuctions,
    List<AuctionModel>? endingSoonAuctions,
    List<AuctionModel>? comingSoonAuctions,
    List<AuctionModel>? myAuctions,
    List<BirdSummaryModel>? featuredBirds,
    List<BirdSummaryModel>? myBirds,
    List<SellerModel>? sellers,
    List<AnnouncementModel>? announcements,
    SellerHomeSummary? sellerSummary,
    CustomerHomeSummary? customerSummary,
    int? unreadNotificationCount,
    int? pointsBalance,
    String? errorMessage,
    bool clearError = false,
    bool clearSellerSummary = false,
    bool clearCustomerSummary = false,
    bool? activeAuctionsLoading,
    bool? endingSoonLoading,
    bool? comingSoonLoading,
    bool? sellersLoading,
    bool? announcementsLoading,
    bool? summaryLoading,
    bool? sellerPrivateLoading,
    bool? featuredBirdsLoading,
  }) =>
      HomeState(
        status: status ?? this.status,
        activeAuctions: activeAuctions ?? this.activeAuctions,
        endingSoonAuctions: endingSoonAuctions ?? this.endingSoonAuctions,
        comingSoonAuctions: comingSoonAuctions ?? this.comingSoonAuctions,
        myAuctions: myAuctions ?? this.myAuctions,
        featuredBirds: featuredBirds ?? this.featuredBirds,
        myBirds: myBirds ?? this.myBirds,
        sellers: sellers ?? this.sellers,
        announcements: announcements ?? this.announcements,
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
        activeAuctionsLoading:
            activeAuctionsLoading ?? this.activeAuctionsLoading,
        endingSoonLoading: endingSoonLoading ?? this.endingSoonLoading,
        comingSoonLoading: comingSoonLoading ?? this.comingSoonLoading,
        sellersLoading: sellersLoading ?? this.sellersLoading,
        announcementsLoading: announcementsLoading ?? this.announcementsLoading,
        summaryLoading: summaryLoading ?? this.summaryLoading,
        sellerPrivateLoading: sellerPrivateLoading ?? this.sellerPrivateLoading,
        featuredBirdsLoading: featuredBirdsLoading ?? this.featuredBirdsLoading,
      );

  @override
  List<Object?> get props => [
        status,
        activeAuctions,
        endingSoonAuctions,
        comingSoonAuctions,
        myAuctions,
        featuredBirds,
        myBirds,
        sellers,
        announcements,
        sellerSummary,
        customerSummary,
        unreadNotificationCount,
        pointsBalance,
        errorMessage,
        activeAuctionsLoading,
        endingSoonLoading,
        comingSoonLoading,
        sellersLoading,
        announcementsLoading,
        summaryLoading,
        sellerPrivateLoading,
        featuredBirdsLoading,
      ];
}
