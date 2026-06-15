part of 'seller_products_bloc.dart';

enum SellerProductsStatus { initial, loading, loaded, error }

enum SellerMutationStatus { idle, creating, updating, deleting, success, failure }

class SellerProductsState extends Equatable {
  final SellerProductsStatus status;
  final SellerMutationStatus mutationStatus;
  final List<SellerProductModel> products;
  final String? selectedCategory;
  final String? errorMessage;
  final String? mutationError;

  const SellerProductsState({
    this.status = SellerProductsStatus.initial,
    this.mutationStatus = SellerMutationStatus.idle,
    this.products = const [],
    this.selectedCategory,
    this.errorMessage,
    this.mutationError,
  });

  List<SellerProductModel> get filteredProducts => selectedCategory == null
      ? products
      : products.where((p) => p.category == selectedCategory).toList();

  SellerProductsState copyWith({
    SellerProductsStatus? status,
    SellerMutationStatus? mutationStatus,
    List<SellerProductModel>? products,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    String? errorMessage,
    bool clearError = false,
    String? mutationError,
    bool clearMutationError = false,
  }) =>
      SellerProductsState(
        status: status ?? this.status,
        mutationStatus: mutationStatus ?? this.mutationStatus,
        products: products ?? this.products,
        selectedCategory: clearSelectedCategory
            ? null
            : selectedCategory ?? this.selectedCategory,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        mutationError:
            clearMutationError ? null : mutationError ?? this.mutationError,
      );

  @override
  List<Object?> get props => [
        status,
        mutationStatus,
        products,
        selectedCategory,
        errorMessage,
        mutationError,
      ];
}
