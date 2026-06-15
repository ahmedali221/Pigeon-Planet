import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/cart_model.dart';
import '../model/cart_repository.dart';
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
}
