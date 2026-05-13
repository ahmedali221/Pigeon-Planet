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
      ];
}
