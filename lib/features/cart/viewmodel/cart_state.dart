part of 'cart_bloc.dart';

enum CartStatus { initial, loading, loaded, mutating, checkingOut, checkedOut, error }

class CartState extends Equatable {
  final CartStatus status;
  final CartModel? cart;
  final OrderModel? lastOrder;
  final List<OrderModel> orders;
  final OrderModel? selectedOrder;
  final List<OrderItemModel> sellerOrderItems;
  final bool ordersLoading;
  final bool sellerItemsLoading;
  final bool itemActioning;
  final String? orderError;
  final String? itemActionError;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.cart,
    this.lastOrder,
    this.orders = const [],
    this.selectedOrder,
    this.sellerOrderItems = const [],
    this.ordersLoading = false,
    this.sellerItemsLoading = false,
    this.itemActioning = false,
    this.orderError,
    this.itemActionError,
    this.errorMessage,
  });

  int get itemsCount => cart?.itemsCount ?? 0;
  bool get isEmpty => cart == null || cart!.items.isEmpty;

  CartState copyWith({
    CartStatus? status,
    CartModel? cart,
    OrderModel? lastOrder,
    List<OrderModel>? orders,
    OrderModel? selectedOrder,
    bool clearSelectedOrder = false,
    List<OrderItemModel>? sellerOrderItems,
    bool? ordersLoading,
    bool? sellerItemsLoading,
    bool? itemActioning,
    String? orderError,
    bool clearOrderError = false,
    String? itemActionError,
    bool clearItemActionError = false,
    String? errorMessage,
  }) =>
      CartState(
        status: status ?? this.status,
        cart: cart ?? this.cart,
        lastOrder: lastOrder ?? this.lastOrder,
        orders: orders ?? this.orders,
        selectedOrder: clearSelectedOrder ? null : (selectedOrder ?? this.selectedOrder),
        sellerOrderItems: sellerOrderItems ?? this.sellerOrderItems,
        ordersLoading: ordersLoading ?? this.ordersLoading,
        sellerItemsLoading: sellerItemsLoading ?? this.sellerItemsLoading,
        itemActioning: itemActioning ?? this.itemActioning,
        orderError: clearOrderError ? null : (orderError ?? this.orderError),
        itemActionError: clearItemActionError ? null : (itemActionError ?? this.itemActionError),
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status, cart, lastOrder, orders, selectedOrder,
        sellerOrderItems, ordersLoading, sellerItemsLoading,
        itemActioning, orderError, itemActionError, errorMessage,
      ];
}
