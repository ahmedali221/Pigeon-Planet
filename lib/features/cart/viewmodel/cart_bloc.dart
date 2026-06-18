import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/cart_model.dart';
import '../model/cart_repository.dart';
import '../model/order_item_model.dart';
import '../model/order_model.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repository;

  CartBloc({required CartRepository repository})
      : _repository = repository,
        super(const CartState()) {
    on<CartStarted>(_onStarted);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemQuantityChanged>(_onItemQuantityChanged);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartCleared>(_onCleared);
    on<CartCheckoutRequested>(_onCheckoutRequested);
    on<OrdersLoadRequested>(_onOrdersLoad);
    on<OrderDetailRequested>(_onOrderDetail);
    on<SellerOrderItemsLoadRequested>(_onSellerItemsLoad);
    on<OrderItemApproveRequested>(_onApproveItem);
    on<OrderItemRejectRequested>(_onRejectItem);
  }

  Future<void> _onStarted(
      CartStarted event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading));
    final result = await _repository.getCart();
    result.fold(
      (f) => emit(state.copyWith(
          status: CartStatus.error, errorMessage: f.message)),
      (cart) => emit(state.copyWith(status: CartStatus.loaded, cart: cart)),
    );
  }

  Future<void> _onItemAdded(
      CartItemAdded event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.mutating));
    final result = await _repository.addItem(event.assetId, event.quantity);
    result.fold(
      (f) => emit(state.copyWith(
          status: CartStatus.error, errorMessage: f.message)),
      (cart) => emit(state.copyWith(status: CartStatus.loaded, cart: cart)),
    );
  }

  Future<void> _onItemQuantityChanged(
      CartItemQuantityChanged event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.mutating));
    final result =
        await _repository.updateItem(event.itemId, event.quantity);
    result.fold(
      (f) => emit(state.copyWith(
          status: CartStatus.error, errorMessage: f.message)),
      (cart) => emit(state.copyWith(status: CartStatus.loaded, cart: cart)),
    );
  }

  Future<void> _onItemRemoved(
      CartItemRemoved event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.mutating));
    final removeResult = await _repository.removeItem(event.itemId);
    await removeResult.fold(
      (f) async => emit(state.copyWith(
          status: CartStatus.error, errorMessage: f.message)),
      (_) async {
        final cartResult = await _repository.getCart();
        cartResult.fold(
          (f) => emit(state.copyWith(
              status: CartStatus.error, errorMessage: f.message)),
          (cart) =>
              emit(state.copyWith(status: CartStatus.loaded, cart: cart)),
        );
      },
    );
  }

  Future<void> _onCleared(
      CartCleared event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.mutating));
    final clearResult = await _repository.clearCart();
    await clearResult.fold(
      (f) async => emit(state.copyWith(
          status: CartStatus.error, errorMessage: f.message)),
      (_) async {
        final cartResult = await _repository.getCart();
        cartResult.fold(
          (f) => emit(state.copyWith(
              status: CartStatus.error, errorMessage: f.message)),
          (cart) =>
              emit(state.copyWith(status: CartStatus.loaded, cart: cart)),
        );
      },
    );
  }

  Future<void> _onCheckoutRequested(
      CartCheckoutRequested event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.checkingOut));
    final result = await _repository.checkout();
    result.fold(
      (f) => emit(state.copyWith(
          status: CartStatus.error, errorMessage: f.message)),
      (order) => emit(state.copyWith(
          status: CartStatus.checkedOut, lastOrder: order)),
    );
  }

  Future<void> _onOrdersLoad(
      OrdersLoadRequested event, Emitter<CartState> emit) async {
    emit(state.copyWith(ordersLoading: true, clearOrderError: true));
    final result = await _repository.getOrders(status: event.status);
    result.fold(
      (f) => emit(state.copyWith(ordersLoading: false, orderError: f.message)),
      (orders) => emit(state.copyWith(ordersLoading: false, orders: orders)),
    );
  }

  Future<void> _onOrderDetail(
      OrderDetailRequested event, Emitter<CartState> emit) async {
    emit(state.copyWith(ordersLoading: true, clearOrderError: true));
    final result = await _repository.getOrderDetail(event.orderId);
    result.fold(
      (f) => emit(state.copyWith(ordersLoading: false, orderError: f.message)),
      (order) => emit(state.copyWith(ordersLoading: false, selectedOrder: order)),
    );
  }

  Future<void> _onSellerItemsLoad(
      SellerOrderItemsLoadRequested event, Emitter<CartState> emit) async {
    emit(state.copyWith(sellerItemsLoading: true, clearOrderError: true));
    final result = await _repository.getSellerOrderItems();
    result.fold(
      (f) => emit(state.copyWith(sellerItemsLoading: false, orderError: f.message)),
      (items) => emit(state.copyWith(sellerItemsLoading: false, sellerOrderItems: items)),
    );
  }

  Future<void> _onApproveItem(
      OrderItemApproveRequested event, Emitter<CartState> emit) async {
    emit(state.copyWith(itemActioning: true, clearItemActionError: true));
    final result = await _repository.approveOrderItem(event.itemId);
    await result.fold(
      (f) async => emit(state.copyWith(itemActioning: false, itemActionError: f.message)),
      (_) async {
        emit(state.copyWith(itemActioning: false));
        add(const SellerOrderItemsLoadRequested());
      },
    );
  }

  Future<void> _onRejectItem(
      OrderItemRejectRequested event, Emitter<CartState> emit) async {
    emit(state.copyWith(itemActioning: true, clearItemActionError: true));
    final result = await _repository.rejectOrderItem(event.itemId);
    await result.fold(
      (f) async => emit(state.copyWith(itemActioning: false, itemActionError: f.message)),
      (_) async {
        emit(state.copyWith(itemActioning: false));
        add(const SellerOrderItemsLoadRequested());
      },
    );
  }
}
