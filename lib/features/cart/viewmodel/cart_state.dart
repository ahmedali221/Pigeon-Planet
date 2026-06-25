part of 'cart_bloc.dart';

enum CartStatus { initial, loading, loaded, mutating, checkingOut, checkedOut, error }

class CartState extends Equatable {
  final CartStatus status;
  final CartModel? cart;
  final OrderModel? lastOrder;
  final PlatformFile? checkoutProofFile;
  final List<OrderModel> orders;
  final OrderModel? selectedOrder;
  final List<OrderItemModel> sellerOrderItems;
  final bool ordersLoading;
  final bool ordersLoadingMore;
  final bool ordersHasMore;
  final int ordersCurrentPage;
  final bool sellerItemsLoading;
  final bool sellerItemsLoadingMore;
  final bool sellerItemsHasMore;
  final int sellerItemsCurrentPage;
  final bool itemActioning;
  final String? orderError;
  final String? itemActionError;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.cart,
    this.lastOrder,
    this.checkoutProofFile,
    this.orders = const [],
    this.selectedOrder,
    this.sellerOrderItems = const [],
    this.ordersLoading = false,
    this.ordersLoadingMore = false,
    this.ordersHasMore = false,
    this.ordersCurrentPage = 1,
    this.sellerItemsLoading = false,
    this.sellerItemsLoadingMore = false,
    this.sellerItemsHasMore = false,
    this.sellerItemsCurrentPage = 1,
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
    PlatformFile? checkoutProofFile,
    bool clearCheckoutProof = false,
    List<OrderModel>? orders,
    OrderModel? selectedOrder,
    bool clearSelectedOrder = false,
    List<OrderItemModel>? sellerOrderItems,
    bool? ordersLoading,
    bool? ordersLoadingMore,
    bool? ordersHasMore,
    int? ordersCurrentPage,
    bool? sellerItemsLoading,
    bool? sellerItemsLoadingMore,
    bool? sellerItemsHasMore,
    int? sellerItemsCurrentPage,
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
        checkoutProofFile: clearCheckoutProof ? null : (checkoutProofFile ?? this.checkoutProofFile),
        orders: orders ?? this.orders,
        selectedOrder: clearSelectedOrder ? null : (selectedOrder ?? this.selectedOrder),
        sellerOrderItems: sellerOrderItems ?? this.sellerOrderItems,
        ordersLoading: ordersLoading ?? this.ordersLoading,
        ordersLoadingMore: ordersLoadingMore ?? this.ordersLoadingMore,
        ordersHasMore: ordersHasMore ?? this.ordersHasMore,
        ordersCurrentPage: ordersCurrentPage ?? this.ordersCurrentPage,
        sellerItemsLoading: sellerItemsLoading ?? this.sellerItemsLoading,
        sellerItemsLoadingMore:
            sellerItemsLoadingMore ?? this.sellerItemsLoadingMore,
        sellerItemsHasMore: sellerItemsHasMore ?? this.sellerItemsHasMore,
        sellerItemsCurrentPage:
            sellerItemsCurrentPage ?? this.sellerItemsCurrentPage,
        itemActioning: itemActioning ?? this.itemActioning,
        orderError: clearOrderError ? null : (orderError ?? this.orderError),
        itemActionError: clearItemActionError ? null : (itemActionError ?? this.itemActionError),
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status, cart, lastOrder, checkoutProofFile, orders, selectedOrder,
        sellerOrderItems, ordersLoading, ordersLoadingMore, ordersHasMore,
        ordersCurrentPage, sellerItemsLoading, sellerItemsLoadingMore,
        sellerItemsHasMore, sellerItemsCurrentPage,
        itemActioning, orderError, itemActionError, errorMessage,
      ];
}
