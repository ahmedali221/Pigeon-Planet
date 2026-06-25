import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/cart_model.dart';
import '../model/cart_repository.dart';
import '../model/order_item_model.dart';
import '../model/order_model.dart';
import '../../payments/model/payment_request_model.dart';
import '../../payments/model/payments_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repository;
  final PaymentsRepository _paymentsRepository;

  CartBloc({
    required CartRepository repository,
    required PaymentsRepository paymentsRepository,
  })  : _repository = repository,
        _paymentsRepository = paymentsRepository,
        super(const CartState()) {
    on<CartStarted>(_onStarted);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemQuantityChanged>(_onItemQuantityChanged);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartCleared>(_onCleared);
    on<CartCheckoutRequested>(_onCheckoutRequested);
    on<OrdersLoadRequested>(_onOrdersLoad);
    on<OrdersLoadMoreRequested>(_onOrdersLoadMore);
    on<OrderDetailRequested>(_onOrderDetail);
    on<SellerOrderItemsLoadRequested>(_onSellerItemsLoad);
    on<SellerOrderItemsLoadMoreRequested>(_onSellerItemsLoadMore);
    on<OrderItemApproveRequested>(_onApproveItem);
    on<OrderItemRejectRequested>(_onRejectItem);
    on<SellerApprovePaymentForItemRequested>(_onApprovePaymentForItem);
    on<SellerRejectPaymentForItemRequested>(_onRejectPaymentForItem);
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
    await result.fold(
      (f) async => emit(state.copyWith(
          status: CartStatus.error, errorMessage: f.message)),
      (order) async {
        // After checkout succeeds, auto-create payment requests for every item.
        // Failures are silently swallowed — the order is already placed.
        if (event.proofFile != null) {
          for (final item in order.items) {
            await _paymentsRepository.createMarketPaymentRequest(
              item.id,
              buyerNote: event.buyerNote,
              proofFile: event.proofFile,
            );
          }
        }
        emit(state.copyWith(
            status: CartStatus.checkedOut,
            lastOrder: order,
            checkoutProofFile: event.proofFile));
        // Reload cart — backend created a new empty active cart on checkout
        final cartResult = await _repository.getCart();
        cartResult.fold(
          (_) => null,
          (cart) => emit(state.copyWith(
              status: CartStatus.checkedOut,
              lastOrder: order,
              checkoutProofFile: event.proofFile,
              cart: cart)),
        );
      },
    );
  }

  Future<void> _onOrdersLoad(
      OrdersLoadRequested event, Emitter<CartState> emit) async {
    emit(state.copyWith(ordersLoading: true, clearOrderError: true));
    final result = await _repository.getOrders(status: event.status, page: 1);
    result.fold(
      (f) => emit(state.copyWith(ordersLoading: false, orderError: f.message)),
      (page) => emit(state.copyWith(
        ordersLoading: false,
        orders: page.items,
        ordersHasMore: page.hasMore,
        ordersCurrentPage: 1,
      )),
    );
  }

  Future<void> _onOrdersLoadMore(
      OrdersLoadMoreRequested event, Emitter<CartState> emit) async {
    if (!state.ordersHasMore || state.ordersLoadingMore) return;
    final nextPage = state.ordersCurrentPage + 1;
    emit(state.copyWith(ordersLoadingMore: true, clearOrderError: true));
    final result =
        await _repository.getOrders(status: event.status, page: nextPage);
    result.fold(
      (f) => emit(state.copyWith(
        ordersLoadingMore: false,
        orderError: f.message,
      )),
      (page) => emit(state.copyWith(
        ordersLoadingMore: false,
        orders: [...state.orders, ...page.items],
        ordersHasMore: page.hasMore,
        ordersCurrentPage: nextPage,
      )),
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
    final result = await _repository.getSellerOrderItems(page: 1);
    result.fold(
      (f) => emit(state.copyWith(sellerItemsLoading: false, orderError: f.message)),
      (page) => emit(state.copyWith(
        sellerItemsLoading: false,
        sellerOrderItems: page.items,
        sellerItemsHasMore: page.hasMore,
        sellerItemsCurrentPage: 1,
      )),
    );
  }

  Future<void> _onSellerItemsLoadMore(
      SellerOrderItemsLoadMoreRequested event, Emitter<CartState> emit) async {
    if (!state.sellerItemsHasMore || state.sellerItemsLoadingMore) return;
    final nextPage = state.sellerItemsCurrentPage + 1;
    emit(state.copyWith(sellerItemsLoadingMore: true, clearOrderError: true));
    final result = await _repository.getSellerOrderItems(page: nextPage);
    result.fold(
      (f) => emit(state.copyWith(
        sellerItemsLoadingMore: false,
        orderError: f.message,
      )),
      (page) => emit(state.copyWith(
        sellerItemsLoadingMore: false,
        sellerOrderItems: [...state.sellerOrderItems, ...page.items],
        sellerItemsHasMore: page.hasMore,
        sellerItemsCurrentPage: nextPage,
      )),
    );
  }

  Future<void> _onApproveItem(
      OrderItemApproveRequested event, Emitter<CartState> emit) async {
    emit(state.copyWith(itemActioning: true, clearItemActionError: true));

    // Step 1: approve the order item
    final approveResult = await _repository.approveOrderItem(event.itemId);
    await approveResult.fold(
      (f) async =>
          emit(state.copyWith(itemActioning: false, itemActionError: f.message)),
      (_) async {
        // Step 2: find and approve the pending payment request for this item
        final requestsResult = await _paymentsRepository.getPaymentRequests();
        await requestsResult.fold(
          (f) async {
            emit(state.copyWith(itemActioning: false, itemActionError: f.message));
          },
          (requests) async {
            final request = requests
                .where((r) => r.orderItemId == event.itemId && r.isPending)
                .firstOrNull;
            if (request == null) {
              // No pending payment request — item approved, nothing more to do
              emit(state.copyWith(itemActioning: false));
              add(const SellerOrderItemsLoadRequested());
              return;
            }
            final paymentResult =
                await _paymentsRepository.approvePaymentRequest(request.id);
            paymentResult.fold(
              (f) => emit(
                  state.copyWith(itemActioning: false, itemActionError: f.message)),
              (_) {
                emit(state.copyWith(itemActioning: false));
                add(const SellerOrderItemsLoadRequested());
              },
            );
          },
        );
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

  Future<void> _onApprovePaymentForItem(
      SellerApprovePaymentForItemRequested event,
      Emitter<CartState> emit) async {
    emit(state.copyWith(itemActioning: true, clearItemActionError: true));
    final requestsResult = await _paymentsRepository.getPaymentRequests();
    await requestsResult.fold(
      (f) async =>
          emit(state.copyWith(itemActioning: false, itemActionError: f.message)),
      (requests) async {
        PaymentRequestModel? request;
        for (final r in requests) {
          if (r.orderItemId == event.orderItemId && r.isPending) {
            request = r;
            break;
          }
        }
        if (request == null) {
          emit(state.copyWith(
            itemActioning: false,
            itemActionError: 'لم يتم العثور على طلب دفع معلق لهذا المنتج',
          ));
          return;
        }
        final approveResult =
            await _paymentsRepository.approvePaymentRequest(request.id);
        approveResult.fold(
          (f) =>
              emit(state.copyWith(itemActioning: false, itemActionError: f.message)),
          (_) {
            emit(state.copyWith(itemActioning: false));
            add(const SellerOrderItemsLoadRequested());
          },
        );
      },
    );
  }

  Future<void> _onRejectPaymentForItem(
      SellerRejectPaymentForItemRequested event,
      Emitter<CartState> emit) async {
    emit(state.copyWith(itemActioning: true, clearItemActionError: true));
    final requestsResult = await _paymentsRepository.getPaymentRequests();
    await requestsResult.fold(
      (f) async =>
          emit(state.copyWith(itemActioning: false, itemActionError: f.message)),
      (requests) async {
        PaymentRequestModel? request;
        for (final r in requests) {
          if (r.orderItemId == event.orderItemId && r.isPending) {
            request = r;
            break;
          }
        }
        if (request == null) {
          emit(state.copyWith(
            itemActioning: false,
            itemActionError: 'لم يتم العثور على طلب دفع معلق لهذا المنتج',
          ));
          return;
        }
        final rejectResult = await _paymentsRepository.rejectPaymentRequest(
          request.id,
          sellerNote: event.sellerNote,
        );
        rejectResult.fold(
          (f) =>
              emit(state.copyWith(itemActioning: false, itemActionError: f.message)),
          (_) {
            emit(state.copyWith(itemActioning: false));
            add(const SellerOrderItemsLoadRequested());
          },
        );
      },
    );
  }
}
