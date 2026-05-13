import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auctions/model/auction_model.dart';
import '../../auctions/model/auctions_repository.dart';
import '../../market/model/market_repository.dart';
import '../../market/model/product_model.dart';
import '../model/datasources/seller_home_remote_datasource.dart';
import '../model/seller_home_summary.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuctionsRepository _auctionsRepository;
  final MarketRepository _marketRepository;
  final SellerHomeRemoteDataSource _sellerHomeRemote;

  HomeBloc({
    required AuctionsRepository auctionsRepository,
    required MarketRepository marketRepository,
    required SellerHomeRemoteDataSource sellerHomeRemote,
  })  : _auctionsRepository = auctionsRepository,
        _marketRepository = marketRepository,
        _sellerHomeRemote = sellerHomeRemote,
        super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshRequested>(_onStarted);
  }

  Future<void> _onStarted(
    HomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      status: HomeStatus.loading,
      clearError: true,
    ));

    final sellerFuture = () async {
      try {
        return await _sellerHomeRemote.fetchHomeSummary();
      } catch (_) {
        return null;
      }
    }();

    final results = await Future.wait([
      _auctionsRepository.getActiveAuctions(),
      _auctionsRepository.getEndingSoon(),
      _marketRepository.getProducts('birds'),
      sellerFuture,
    ]);

    final activeResult = results[0] as dynamic;
    final endingResult = results[1] as dynamic;
    final birdsResult = results[2] as dynamic;
    final sellerSummary = results[3] as SellerHomeSummary?;

    String? errorMessage;

    final activeAuctions = activeResult.fold(
      (failure) {
        errorMessage = failure.toString();
        return <AuctionModel>[];
      },
      (list) => list as List<AuctionModel>,
    );
    final endingSoon = endingResult.fold(
      (failure) {
        errorMessage ??= failure.toString();
        return <AuctionModel>[];
      },
      (list) => list as List<AuctionModel>,
    );
    final featuredBirds = birdsResult.fold(
      (failure) {
        errorMessage ??= failure.toString();
        return <ProductModel>[];
      },
      (list) => list as List<ProductModel>,
    );

    final allFailed = activeAuctions.isEmpty &&
        endingSoon.isEmpty &&
        featuredBirds.isEmpty &&
        errorMessage != null;

    emit(state.copyWith(
      status: allFailed ? HomeStatus.error : HomeStatus.loaded,
      activeAuctions: activeAuctions,
      endingSoonAuctions: endingSoon,
      featuredBirds: featuredBirds,
      sellerSummary: sellerSummary,
      errorMessage: errorMessage,
    ));
  }
}
