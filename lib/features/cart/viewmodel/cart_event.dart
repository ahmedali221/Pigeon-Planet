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
  final PlatformFile? proofFile;
  final String? buyerNote;
  const CartCheckoutRequested({this.proofFile, this.buyerNote});
  @override
  List<Object?> get props => [proofFile?.path, buyerNote];
}

class OrdersLoadRequested extends CartEvent {
  final String? status;
  const OrdersLoadRequested({this.status});
  @override
  List<Object?> get props => [status];
}

class OrdersLoadMoreRequested extends CartEvent {
  final String? status;
  const OrdersLoadMoreRequested({this.status});
  @override
  List<Object?> get props => [status];
}

class OrderDetailRequested extends CartEvent {
  final int orderId;
  const OrderDetailRequested(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class SellerOrderItemsLoadRequested extends CartEvent {
  const SellerOrderItemsLoadRequested();
  @override
  List<Object?> get props => [];
}

class SellerOrderItemsLoadMoreRequested extends CartEvent {
  const SellerOrderItemsLoadMoreRequested();
  @override
  List<Object?> get props => [];
}

class OrderItemApproveRequested extends CartEvent {
  final int itemId;
  const OrderItemApproveRequested(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class OrderItemRejectRequested extends CartEvent {
  final int itemId;
  const OrderItemRejectRequested(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class SellerApprovePaymentForItemRequested extends CartEvent {
  final int orderItemId;
  const SellerApprovePaymentForItemRequested(this.orderItemId);
  @override
  List<Object?> get props => [orderItemId];
}

class SellerRejectPaymentForItemRequested extends CartEvent {
  final int orderItemId;
  final String? sellerNote;
  const SellerRejectPaymentForItemRequested(this.orderItemId,
      {this.sellerNote});
  @override
  List<Object?> get props => [orderItemId, sellerNote];
}
