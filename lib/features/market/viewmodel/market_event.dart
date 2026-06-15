part of 'market_bloc.dart';

abstract class MarketEvent extends Equatable {
  const MarketEvent();

  @override
  List<Object?> get props => [];
}

class MarketStarted extends MarketEvent {
  const MarketStarted();
}

class MarketCategorySelected extends MarketEvent {
  final CategoryModel category;
  const MarketCategorySelected(this.category);

  @override
  List<Object?> get props => [category.id];
}

class MarketSearchChanged extends MarketEvent {
  final String query;
  const MarketSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class MarketProductOpened extends MarketEvent {
  final ProductModel product;
  const MarketProductOpened(this.product);

  @override
  List<Object?> get props => [product.id];
}

class MarketWeightSelected extends MarketEvent {
  final String weight;
  const MarketWeightSelected(this.weight);

  @override
  List<Object?> get props => [weight];
}

class MarketQuantityIncreased extends MarketEvent {
  const MarketQuantityIncreased();
}

class MarketQuantityDecreased extends MarketEvent {
  const MarketQuantityDecreased();
}

class MarketAddToCart extends MarketEvent {
  const MarketAddToCart();
}

class MarketFavoriteToggled extends MarketEvent {
  final String productId;
  const MarketFavoriteToggled(this.productId);

  @override
  List<Object?> get props => [productId];
}

