import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auctions/model/auction_model.dart';
import '../../auctions/model/auctions_repository.dart';
import '../../auctions/model/bird_summary_model.dart';
import '../model/customer_home_summary.dart';
import '../model/datasources/points_remote_datasource.dart';
import '../model/datasources/seller_home_remote_datasource.dart';
import '../model/seller_home_summary.dart';
import '../model/seller_model.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuctionsRepository _auctionsRepository;
  final SellerHomeRemoteDataSource _sellerHomeRemote;
  final PointsRemoteDataSource _pointsRemote;

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
  }

  Future<void> _onStarted(HomeEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));
    final shouldLoadSellerPrivateData = event.isSeller;

    final sellerFuture = () async {
      try {
        return await _sellerHomeRemote.fetchHomeSummary();
      } catch (_) {
        return null;
      }
    }();

    final customerFuture = () async {
      try {
        return await _sellerHomeRemote.fetchCustomerHomeSummary();
      } catch (_) {
        return null;
      }
    }();

    final unreadFuture = () async {
      try {
        return await _sellerHomeRemote.fetchUnreadNotificationCount();
      } catch (_) {
        return 0;
      }
    }();

    final pointsFuture = () async {
      try {
        if (shouldLoadSellerPrivateData) {
          return await _pointsRemote.fetchBalance();
        }
        return await _pointsRemote.fetchLoyaltyBalance();
      } catch (_) {
        return null;
      }
    }();

    final sellersFuture = () async {
      try {
        return await _sellerHomeRemote.fetchSellers();
      } catch (_) {
        return <SellerModel>[];
      }
    }();

    final results = await Future.wait([
      _auctionsRepository.getActiveAuctions(), // 0
      _auctionsRepository.getEndingSoon(), // 1
      sellerFuture, // 2
      customerFuture, // 3
      unreadFuture, // 4
      pointsFuture, // 5
      _auctionsRepository.getAuctions(), // 6
      sellersFuture, // 7
    ]);

    final activeResult = results[0] as dynamic;
    final endingResult = results[1] as dynamic;
    final remoteSellerSummary = results[2] as SellerHomeSummary?;
    final remoteCustomerSummary = results[3] as CustomerHomeSummary?;
    final unreadCount = results[4] as int;
    final pointsBalance = results[5] as int?;
    final comingSoonResult = results[6] as dynamic;
    final sellers = results[7] as List<SellerModel>;

    String? errorMessage;

    final activeAuctions = activeResult.fold((failure) {
      errorMessage = failure.toString();
      return <AuctionModel>[];
    }, (list) => list as List<AuctionModel>);
    final endingSoon = endingResult.fold((failure) {
      errorMessage ??= failure.toString();
      return <AuctionModel>[];
    }, (list) => list as List<AuctionModel>);
    const featuredBirds = <BirdSummaryModel>[];
    final comingSoon = comingSoonResult.fold(
      (_) => <AuctionModel>[],
      (list) => list as List<AuctionModel>,
    );
    var myBirds = <BirdSummaryModel>[];
    var myAuctions = <AuctionModel>[];
    if (shouldLoadSellerPrivateData) {
      final myBirdsResult = await _auctionsRepository.getSellerBirds(
        mineOnly: true,
      );
      myBirds = myBirdsResult.fold((_) => <BirdSummaryModel>[], (list) => list);
      final myAuctionsResult = await _auctionsRepository.getMyAuctions();
      myAuctions = myAuctionsResult.fold(
        (_) => <AuctionModel>[],
        (list) => list,
      );
    }

    final sellerSummary =
        remoteSellerSummary ??
        _buildSellerSummary(
          myAuctions: myAuctions,
          myBirds: myBirds,
          pointsBalance: pointsBalance,
          unreadCount: unreadCount,
        );
    final customerSummary =
        remoteCustomerSummary ??
        _buildCustomerSummary(
          pointsBalance: pointsBalance,
          unreadCount: unreadCount,
        );

    final allFailed =
        activeAuctions.isEmpty &&
        endingSoon.isEmpty &&
        featuredBirds.isEmpty &&
        errorMessage != null;

    emit(
      state.copyWith(
        status: allFailed ? HomeStatus.error : HomeStatus.loaded,
        activeAuctions: activeAuctions,
        endingSoonAuctions: endingSoon,
        comingSoonAuctions: comingSoon,
        featuredBirds: featuredBirds,
        myBirds: myBirds,
        sellers: sellers,
        sellerSummary: sellerSummary,
        customerSummary: customerSummary,
        unreadNotificationCount: unreadCount,
        pointsBalance: pointsBalance,
        errorMessage: errorMessage,
      ),
    );
  }

  SellerHomeSummary _buildSellerSummary({
    required List<AuctionModel> myAuctions,
    required List<BirdSummaryModel> myBirds,
    required int? pointsBalance,
    required int unreadCount,
  }) {
    final activeAuctions = myAuctions.where((a) => a.isActive).length;
    return SellerHomeSummary(
      nickname: '',
      balance: '0',
      currency: 'EGP',
      subscriptionTier: null,
      pointsBalance: pointsBalance,
      profileActivated: true,
      activeLiveAuctions: activeAuctions,
      myActiveListings: myBirds.length,
      salesToday: 0,
      pendingOrderItems: 0,
      notifications: const [],
      notificationsNewCount: unreadCount,
      providerNotes: [
        const SellerProviderNote(
          key: 'backend_summary',
          title: 'بيانات مباشرة',
          subtitle: 'تم تجميع الملخص من المزادات والطيور والنقاط المتاحة',
          accent: 'primary',
          done: true,
        ),
        SellerProviderNote(
          key: 'points',
          title: 'النقاط',
          subtitle: pointsBalance == null
              ? 'لا توجد بيانات نقاط بعد'
              : '$pointsBalance نقطة متاحة',
          accent: pointsBalance == null ? 'orange' : 'primary',
          done: pointsBalance != null,
        ),
      ],
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
