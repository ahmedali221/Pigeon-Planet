part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
}

class CartStarted extends CartEvent {
  const CartStarted();
  @override
  List<Object?> get props => [];
}

class CartItemAdded extends CartEvent {
  final int assetId;
  final int quantity;
  const CartItemAdded(this.assetId, this.quantity);
  @override
  List<Object?> get props => [assetId, quantity];
}

class CartItemQuantityChanged extends CartEvent {
  final int itemId;
  final int quantity;
  const CartItemQuantityChanged(this.itemId, this.quantity);
  @override
  List<Object?> get props => [itemId, quantity];
}

class CartItemRemoved extends CartEvent {
  final int itemId;
  const CartItemRemoved(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class CartCleared extends CartEvent {
  const CartCleared();
  @override
  List<Object?> get props => [];
}

class CartCheckoutRequested extends CartEvent {
  const CartCheckoutRequested();
  @override
  List<Object?> get props => [];
}
