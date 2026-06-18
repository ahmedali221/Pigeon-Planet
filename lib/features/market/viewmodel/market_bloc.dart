import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/cashback_offer_model.dart';
import '../model/category_model.dart';
import '../model/discount_offer_model.dart';
import '../model/market_feed_result.dart';
import '../model/market_mock_data.dart';
import '../model/market_repository.dart';
import '../model/product_model.dart';

part 'market_event.dart';
part 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final MarketRepository _repository;

  MarketBloc({required MarketRepository repository})
      : _repository = repository,
        super(const MarketState()) {
    on<MarketStarted>(_onStarted);
    on<MarketCategorySelected>(_onCategorySelected);
    on<MarketSearchChanged>(_onSearchChanged);
    on<MarketProductOpened>(_onProductOpened);
    on<MarketWeightSelected>(_onWeightSelected);
    on<MarketQuantityIncreased>(_onQuantityIncreased);
    on<MarketQuantityDecreased>(_onQuantityDecreased);
    on<MarketAddToCart>(_onAddToCart);
    on<MarketFavoriteToggled>(_onFavoriteToggled);
    on<MarketFeedLoadMoreRequested>(_onFeedLoadMore);
    on<MarketSortChanged>(_onSortChanged);
  }

  Future<void> _onStarted(
    MarketStarted event,
    Emitter<MarketState> emit,
  ) async {
    final categories = MarketMockData.categories;
    emit(state.copyWith(
      status: MarketStatus.loading,
      categories: categories,
      feedLoading: true,
    ));

    // Kick off all network requests in parallel
    final productsFut = categories.isNotEmpty
        ? _repository.getProducts(categories.first.id)
        : null;
    final discountsFut = _repository.getDiscountOffers();
    final cashbackFut = _repository.getCashbackOffers();
    final feedFut = _repository.getFeedMarket();

    final productsResult = await productsFut;
    final discountsResult = await discountsFut;
    final cashbackResult = await cashbackFut;
    final feedResult = await feedFut;

    final discounts = discountsResult.getOrElse(() => []);
    final cashbacks = cashbackResult.getOrElse(() => []);

    MarketFeedResult? feedData;
    feedResult.fold((_) {}, (r) => feedData = r);

    if (productsResult != null) {
      productsResult.fold(
        (f) => emit(state.copyWith(
          status: MarketStatus.categoriesLoaded,
          allProducts: MarketMockData.products,
          filteredProducts: MarketMockData.products
              .where((p) => p.categoryId == categories.first.id)
              .toList(),
          selectedCategory: categories.first,
          discountOffers: discounts,
          cashbackOffers: cashbacks,
          feedProducts: feedData?.products ?? [],
          feedCursor: feedData?.nextCursor,
          feedHasMore: feedData?.nextCursor != null,
          feedLoading: false,
        )),
        (products) => emit(state.copyWith(
          status: MarketStatus.productsLoaded,
          allProducts: products,
          filteredProducts: products,
          selectedCategory: categories.first,
          discountOffers: discounts,
          cashbackOffers: cashbacks,
          feedProducts: feedData?.products ?? [],
          feedCursor: feedData?.nextCursor,
          feedHasMore: feedData?.nextCursor != null,
          feedLoading: false,
        )),
      );
    } else {
      emit(state.copyWith(
        status: MarketStatus.categoriesLoaded,
        discountOffers: discounts,
        cashbackOffers: cashbacks,
        feedLoading: false,
      ));
    }
  }

  Future<void> _onCategorySelected(
    MarketCategorySelected event,
    Emitter<MarketState> emit,
  ) async {
    emit(state.copyWith(
      status: MarketStatus.loading,
      selectedCategory: event.category,
      searchQuery: '',
    ));

    final result = await _repository.getProducts(
      event.category.id,
      ordering: state.activeOrdering,
    );
    result.fold(
      (f) {
        final fallback = MarketMockData.products
            .where((p) => p.categoryId == event.category.id)
            .toList();
        emit(state.copyWith(
          status: MarketStatus.productsLoaded,
          allProducts: fallback,
          filteredProducts: fallback,
        ));
      },
      (products) => emit(state.copyWith(
        status: MarketStatus.productsLoaded,
        allProducts: products,
        filteredProducts: products,
      )),
    );
  }

  Future<void> _onSearchChanged(
    MarketSearchChanged event,
    Emitter<MarketState> emit,
  ) async {
    final q = event.query;
    emit(state.copyWith(searchQuery: q));

    if (state.selectedCategory == null) return;

    if (q.isEmpty) {
      final result = await _repository.getProducts(state.selectedCategory!.id);
      result.fold(
        (_) {},
        (products) => emit(state.copyWith(
          allProducts: products,
          filteredProducts: products,
        )),
      );
      return;
    }

    if (q.length < 2) {
      final filtered = state.allProducts
          .where((p) => p.name.toLowerCase().contains(q.toLowerCase()))
          .toList();
      emit(state.copyWith(filteredProducts: filtered));
      return;
    }

    final result =
        await _repository.getProducts(state.selectedCategory!.id, query: q);
    result.fold(
      (_) {
        final filtered = state.allProducts
            .where((p) => p.name.toLowerCase().contains(q.toLowerCase()))
            .toList();
        emit(state.copyWith(filteredProducts: filtered));
      },
      (products) => emit(state.copyWith(
        allProducts: products,
        filteredProducts: products,
      )),
    );
  }

  Future<void> _onSortChanged(
    MarketSortChanged event,
    Emitter<MarketState> emit,
  ) async {
    if (state.selectedCategory == null) return;
    emit(state.copyWith(
      status: MarketStatus.loading,
      activeOrdering: event.ordering,
      clearOrdering: event.ordering == null,
    ));
    final result = await _repository.getProducts(
      state.selectedCategory!.id,
      ordering: event.ordering,
    );
    result.fold(
      (_) {},
      (products) => emit(state.copyWith(
        status: MarketStatus.productsLoaded,
        allProducts: products,
        filteredProducts: products,
      )),
    );
  }

  Future<void> _onFeedLoadMore(
    MarketFeedLoadMoreRequested event,
    Emitter<MarketState> emit,
  ) async {
    if (!state.feedHasMore || state.feedLoading) return;
    emit(state.copyWith(feedLoading: true));

    final result = await _repository.getFeedMarket(cursor: state.feedCursor);
    result.fold(
      (_) => emit(state.copyWith(feedLoading: false)),
      (data) => emit(state.copyWith(
        feedProducts: [...state.feedProducts, ...data.products],
        feedCursor: data.nextCursor,
        feedHasMore: data.nextCursor != null,
        feedLoading: false,
      )),
    );
  }

  void _onProductOpened(
    MarketProductOpened event,
    Emitter<MarketState> emit,
  ) {
    emit(state.copyWith(
      status: MarketStatus.productDetail,
      selectedProduct: event.product,
      quantity: 1,
    ));
  }

  void _onWeightSelected(
    MarketWeightSelected event,
    Emitter<MarketState> emit,
  ) {
    emit(state.copyWith(selectedWeight: event.weight));
  }

  void _onQuantityIncreased(
    MarketQuantityIncreased event,
    Emitter<MarketState> emit,
  ) {
    emit(state.copyWith(quantity: state.quantity + 1));
  }

  void _onQuantityDecreased(
    MarketQuantityDecreased event,
    Emitter<MarketState> emit,
  ) {
    if (state.quantity > 1) {
      emit(state.copyWith(quantity: state.quantity - 1));
    }
  }

  void _onAddToCart(MarketAddToCart event, Emitter<MarketState> emit) {
    emit(state.copyWith(cartCount: state.cartCount + state.quantity));
  }

  void _onFavoriteToggled(
    MarketFavoriteToggled event,
    Emitter<MarketState> emit,
  ) {
    final updated = state.allProducts.map((p) {
      return p.id == event.productId
          ? p.copyWith(isFavorite: !p.isFavorite)
          : p;
    }).toList();
    final updatedFiltered = state.filteredProducts.map((p) {
      return p.id == event.productId
          ? p.copyWith(isFavorite: !p.isFavorite)
          : p;
    }).toList();
    final updatedSelected =
        state.selectedProduct?.id == event.productId
            ? state.selectedProduct!
                .copyWith(isFavorite: !state.selectedProduct!.isFavorite)
            : state.selectedProduct;
    emit(state.copyWith(
      allProducts: updated,
      filteredProducts: updatedFiltered,
      selectedProduct: updatedSelected,
    ));
  }
}
