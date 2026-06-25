import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auctions/model/auction_model.dart';
import '../../auctions/model/auctions_repository.dart';
import '../../auctions/model/bird_summary_model.dart';
import '../model/announcement_model.dart';
import '../model/customer_home_summary.dart';
import '../model/datasources/points_remote_datasource.dart';
import '../model/datasources/seller_home_remote_datasource.dart';
import '../model/seller_home_summary.dart';
import '../model/seller_model.dart';

part 'home_event.dart';
part 'home_state.dart';

class _UnreadCountTick extends HomeEvent {
  const _UnreadCountTick();
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuctionsRepository _auctionsRepository;
  final SellerHomeRemoteDataSource _sellerHomeRemote;
  final PointsRemoteDataSource _pointsRemote;
  Timer? _pollTimer;

  HomeBloc({
    required AuctionsRepository auctionsRepository,
    required SellerHomeRemoteDataSource sellerHomeRemote,
    required PointsRemoteDataSource pointsRemote,
  }) : _auctionsRepository = auctionsRepository,
       _sellerHomeRemote = sellerHomeRemote,
       _pointsRemote = pointsRemote,
       super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshRequested>(_onStarted);
    on<_UnreadCountTick>(_onUnreadCountTick);
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  Future<void> _onStarted(HomeEvent event, Emitter<HomeState> emit) async {
    final isSeller = event.isSeller;

    // Immediately render the page with skeletons in every section.
    emit(state.copyWith(
      status: HomeStatus.loading,
      clearError: true,
      activeAuctionsLoading: true,
      endingSoonLoading: true,
      comingSoonLoading: true,
      sellersLoading: true,
      announcementsLoading: true,
      summaryLoading: true,
      sellerPrivateLoading: isSeller,
      featuredBirdsLoading: true,
    ));

    // Fire all independent sections in parallel — each emits as soon as it resolves.
    await Future.wait([
      _loadActiveAuctions(emit),
      _loadEndingSoon(emit),
      _loadComingSoon(emit),
      _loadSellers(emit),
      _loadAnnouncements(emit),
      _loadSummary(emit, isSeller),
      _loadFeaturedBirds(emit),
    ]);

    // Seller-only private data (sequential by design — birds before auctions).
    if (isSeller) {
      await _loadSellerPrivate(emit, isSeller);
    }

    emit(state.copyWith(status: HomeStatus.loaded));

    _pollTimer ??= Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isClosed) add(const _UnreadCountTick());
    });
  }

  Future<void> _loadFeaturedBirds(Emitter<HomeState> emit) async {
    final result = await _auctionsRepository.getSellerBirds();
    final birds = result.fold((_) => <BirdSummaryModel>[], (list) => list);
    emit(state.copyWith(featuredBirds: birds, featuredBirdsLoading: false));
  }

  Future<void> _loadActiveAuctions(Emitter<HomeState> emit) async {
    String? errorMsg;
    final result = await _auctionsRepository.getActiveAuctions();
    final auctions = result.fold(
      (failure) {
        errorMsg = failure.toString();
        return <AuctionModel>[];
      },
      (list) => list,
    );
    emit(state.copyWith(
      activeAuctions: auctions,
      activeAuctionsLoading: false,
      errorMessage: errorMsg,
      clearError: errorMsg == null,
    ));
  }

  Future<void> _loadEndingSoon(Emitter<HomeState> emit) async {
    final result = await _auctionsRepository.getEndingSoon();
    final auctions = result.fold(
      (_) => <AuctionModel>[],
      (list) => list,
    );
    emit(state.copyWith(endingSoonAuctions: auctions, endingSoonLoading: false));
  }

  Future<void> _loadComingSoon(Emitter<HomeState> emit) async {
    final result = await _auctionsRepository.getAuctions();
    final auctions = result.fold(
      (_) => <AuctionModel>[],
      (page) => page.items,
    );
    emit(state.copyWith(comingSoonAuctions: auctions, comingSoonLoading: false));
  }

  Future<void> _loadSellers(Emitter<HomeState> emit) async {
    try {
      final sellers = await _sellerHomeRemote.fetchSellers();
      emit(state.copyWith(sellers: sellers, sellersLoading: false));
    } catch (_) {
      emit(state.copyWith(sellers: const [], sellersLoading: false));
    }
  }

  Future<void> _loadAnnouncements(Emitter<HomeState> emit) async {
    try {
      final announcements = await _sellerHomeRemote.fetchAnnouncements();
      emit(state.copyWith(announcements: announcements, announcementsLoading: false));
    } catch (_) {
      emit(state.copyWith(announcements: const [], announcementsLoading: false));
    }
  }

  Future<void> _loadSummary(Emitter<HomeState> emit, bool isSeller) async {
    SellerHomeSummary? remoteSellerSummary;
    CustomerHomeSummary? remoteCustomerSummary;
    int unreadCount = 0;
    int? pointsBalance;

    await Future.wait([
      () async {
        if (!isSeller) return;
        try {
          remoteSellerSummary = await _sellerHomeRemote.fetchHomeSummary();
        } catch (_) {}
      }(),
      () async {
        try {
          remoteCustomerSummary =
              await _sellerHomeRemote.fetchCustomerHomeSummary();
        } catch (_) {}
      }(),
      () async {
        try {
          unreadCount =
              await _sellerHomeRemote.fetchUnreadNotificationCount();
        } catch (_) {}
      }(),
      () async {
        try {
          pointsBalance = isSeller
              ? await _pointsRemote.fetchBalance()
              : await _pointsRemote.fetchLoyaltyBalance();
        } catch (_) {}
      }(),
    ]);

    final sellerSummary = remoteSellerSummary ??
        _buildSellerSummary(
          myAuctions: const [],
          myBirds: const [],
          pointsBalance: pointsBalance,
          unreadCount: unreadCount,
        );
    final customerSummary = remoteCustomerSummary ??
        _buildCustomerSummary(
          pointsBalance: pointsBalance,
          unreadCount: unreadCount,
        );

    emit(state.copyWith(
      sellerSummary: sellerSummary,
      customerSummary: customerSummary,
      unreadNotificationCount: unreadCount,
      pointsBalance: pointsBalance,
      summaryLoading: false,
    ));
  }

  Future<void> _loadSellerPrivate(Emitter<HomeState> emit, bool isSeller) async {
    final birdsResult = await _auctionsRepository.getSellerBirds(mineOnly: true);
    final myBirds =
        birdsResult.fold((_) => <BirdSummaryModel>[], (list) => list);
    // Emit birds immediately so the metrics count updates as soon as possible.
    emit(state.copyWith(myBirds: myBirds));

    final auctionsResult = await _auctionsRepository.getMyAuctions();
    final myAuctions =
        auctionsResult.fold((_) => <AuctionModel>[], (list) => list);

    // If the summary API failed (nickname is empty), build a fallback from local data
    // but preserve any notifications that were already fetched from the API.
    final existingSummary = state.sellerSummary;
    final needsFallback = existingSummary == null ||
        existingSummary.nickname.isEmpty;
    emit(state.copyWith(
      sellerSummary: needsFallback
          ? _buildSellerSummary(
              myAuctions: myAuctions,
              myBirds: myBirds,
              pointsBalance: state.pointsBalance,
              unreadCount: state.unreadNotificationCount,
              existingNotifications: existingSummary?.notifications,
            )
          : null, // keep the API-fetched summary
      sellerPrivateLoading: false,
    ));
  }

  Future<void> _onUnreadCountTick(
    _UnreadCountTick event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final count = await _sellerHomeRemote.fetchUnreadNotificationCount();
      emit(state.copyWith(unreadNotificationCount: count));
    } catch (_) {}
  }

  SellerHomeSummary _buildSellerSummary({
    required List<AuctionModel> myAuctions,
    required List<BirdSummaryModel> myBirds,
    required int? pointsBalance,
    required int unreadCount,
    List<SellerHomeNotification>? existingNotifications,
  }) {
    final activeAuctions = myAuctions.where((a) => a.isActive).length;
    final closedAuctions = myAuctions.where((a) => a.isEnded).length;
    return SellerHomeSummary(
      nickname: '',
      balance: '0',
      currency: 'EGP',
      profileActivated: true,
      pointsBalance: pointsBalance,
      activeLiveAuctions: activeAuctions,
      auctionClosedCount: closedAuctions,
      myActiveListings: myBirds.length,
      pendingOrderItems: 0,
      notifications: existingNotifications ?? const [],
      notificationsNewCount: unreadCount,
      providerNotes: const [],
    );
  }

  CustomerHomeSummary _buildCustomerSummary({
    required int? pointsBalance,
    required int unreadCount,
  }) {
    return CustomerHomeSummary(
      nickname: '',
      balance: '0',
      currency: 'EGP',
      openOrders: 0,
      pendingOrderItems: 0,
      notifications: const [],
      notificationsNewCount: unreadCount,
    );
  }
}
