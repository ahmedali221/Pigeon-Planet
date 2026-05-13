import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/category_model.dart';
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
  }

  Future<void> _onStarted(
    MarketStarted event,
    Emitter<MarketState> emit,
  ) async {
    final categories = MarketMockData.categories;
    emit(state.copyWith(
      status: MarketStatus.loading,
      categories: categories,
    ));

    if (categories.isNotEmpty) {
      final result =
          await _repository.getProducts(categories.first.id);
      result.fold(
        (f) => emit(state.copyWith(
          status: MarketStatus.categoriesLoaded,
          allProducts: MarketMockData.products,
          filteredProducts: MarketMockData.products
              .where((p) => p.categoryId == categories.first.id)
              .toList(),
          selectedCategory: categories.first,
        )),
        (products) => emit(state.copyWith(
          status: MarketStatus.productsLoaded,
          allProducts: products,
          filteredProducts: products,
          selectedCategory: categories.first,
        )),
      );
    } else {
      emit(state.copyWith(status: MarketStatus.categoriesLoaded));
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

    final result = await _repository.getProducts(event.category.id);
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

  void _onSearchChanged(
    MarketSearchChanged event,
    Emitter<MarketState> emit,
  ) {
    final q = event.query.toLowerCase();
    final filtered = q.isEmpty
        ? state.allProducts
        : state.allProducts
            .where((p) => p.name.toLowerCase().contains(q))
            .toList();
    emit(state.copyWith(
      searchQuery: event.query,
      filteredProducts: filtered,
    ));
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
