part of 'seller_products_bloc.dart';

abstract class SellerProductsEvent extends Equatable {
  const SellerProductsEvent();

  @override
  List<Object?> get props => [];
}

class SellerProductsStarted extends SellerProductsEvent {
  const SellerProductsStarted();
}

class SellerProductsRefreshRequested extends SellerProductsEvent {
  const SellerProductsRefreshRequested();
}

class SellerProductCategoryFiltered extends SellerProductsEvent {
  final String? category;
  const SellerProductCategoryFiltered(this.category);

  @override
  List<Object?> get props => [category];
}

class SellerProductCreateRequested extends SellerProductsEvent {
  final SellerProductPayload payload;
  const SellerProductCreateRequested(this.payload);

  @override
  List<Object?> get props => [payload];
}

class SellerProductUpdateRequested extends SellerProductsEvent {
  final int id;
  final String category;
  final SellerProductUpdatePayload payload;

  const SellerProductUpdateRequested({
    required this.id,
    required this.category,
    required this.payload,
  });

  @override
  List<Object?> get props => [id, category];
}

class SellerProductDeleteRequested extends SellerProductsEvent {
  final int id;
  final String category;

  const SellerProductDeleteRequested({required this.id, required this.category});

  @override
  List<Object?> get props => [id, category];
}

class SellerProductsLoadMoreRequested extends SellerProductsEvent {
  const SellerProductsLoadMoreRequested();
}
