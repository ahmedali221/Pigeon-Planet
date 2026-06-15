part of 'cart_bloc.dart';

enum CartStatus { initial, loading, loaded, mutating, checkingOut, checkedOut, error }

class CartState extends Equatable {
  final CartStatus status;
  final CartModel? cart;
  final OrderModel? lastOrder;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.cart,
    this.lastOrder,
    this.errorMessage,
  });

  int get itemsCount => cart?.itemsCount ?? 0;
  bool get isEmpty => cart == null || cart!.items.isEmpty;

  CartState copyWith({
    CartStatus? status,
    CartModel? cart,
    OrderModel? lastOrder,
    String? errorMessage,
  }) =>
      CartState(
        status: status ?? this.status,
        cart: cart ?? this.cart,
        lastOrder: lastOrder ?? this.lastOrder,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, cart, lastOrder, errorMessage];
}
