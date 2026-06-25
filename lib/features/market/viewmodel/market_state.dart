part of 'market_bloc.dart';

enum MarketStatus { initial, loading, categoriesLoaded, productsLoaded, productDetail, error }

class MarketState extends Equatable {
  final MarketStatus status;
  final List<CategoryModel> categories;
  final List<ProductModel> allProducts;
  final List<ProductModel> filteredProducts;
  final CategoryModel? selectedCategory;
  final ProductModel? selectedProduct;
  final String searchQuery;
  final String? selectedWeight;
  final int quantity;
  final int cartCount;
  final String? errorMessage;

  // Personalized market feed
  final List<ProductModel> feedProducts;
  final String? feedCursor;
  final bool feedHasMore;
  final bool feedLoading;

  // Active promotions
  final List<DiscountOfferModel> discountOffers;
  final List<CashbackOfferModel> cashbackOffers;

  // Ordering — null = default (newest first)
  final String? activeOrdering;

  // Total market-listed products across all categories
  final int totalProductsCount;

  const MarketState({
    this.status = MarketStatus.initial,
    this.categories = const [],
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.selectedCategory,
    this.selectedProduct,
    this.searchQuery = '',
    this.selectedWeight,
    this.quantity = 1,
    this.cartCount = 0,
    this.errorMessage,
    this.feedProducts = const [],
    this.feedCursor,
    this.feedHasMore = false,
    this.feedLoading = false,
    this.discountOffers = const [],
    this.cashbackOffers = const [],
    this.activeOrdering,
    this.totalProductsCount = 0,
  });

  double get currentPrice {
    if (selectedProduct == null) return 0;
    return selectedProduct!.price * quantity;
  }

  MarketState copyWith({
    MarketStatus? status,
    List<CategoryModel>? categories,
    List<ProductModel>? allProducts,
    List<ProductModel>? filteredProducts,
    CategoryModel? selectedCategory,
    ProductModel? selectedProduct,
    String? searchQuery,
    String? selectedWeight,
    int? quantity,
    int? cartCount,
    String? errorMessage,
    List<ProductModel>? feedProducts,
    String? feedCursor,
    bool? feedHasMore,
    bool? feedLoading,
    List<DiscountOfferModel>? discountOffers,
    List<CashbackOfferModel>? cashbackOffers,
    String? activeOrdering,
    bool clearOrdering = false,
    int? totalProductsCount,
  }) {
    return MarketState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedWeight: selectedWeight ?? this.selectedWeight,
      quantity: quantity ?? this.quantity,
      cartCount: cartCount ?? this.cartCount,
      errorMessage: errorMessage ?? this.errorMessage,
      feedProducts: feedProducts ?? this.feedProducts,
      feedCursor: feedCursor ?? this.feedCursor,
      feedHasMore: feedHasMore ?? this.feedHasMore,
      feedLoading: feedLoading ?? this.feedLoading,
      discountOffers: discountOffers ?? this.discountOffers,
      cashbackOffers: cashbackOffers ?? this.cashbackOffers,
      activeOrdering: clearOrdering ? null : (activeOrdering ?? this.activeOrdering),
      totalProductsCount: totalProductsCount ?? this.totalProductsCount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        allProducts,
        filteredProducts,
        selectedCategory?.id,
        selectedProduct?.id,
        searchQuery,
        selectedWeight,
        quantity,
        cartCount,
        errorMessage,
        feedProducts,
        feedCursor,
        feedHasMore,
        feedLoading,
        discountOffers,
        cashbackOffers,
        activeOrdering,
        totalProductsCount,
      ];
}
