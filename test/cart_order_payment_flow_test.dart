import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pigeon_planet/core/error/failures.dart';
import 'package:pigeon_planet/features/cart/model/cart_item_model.dart';
import 'package:pigeon_planet/features/cart/model/cart_model.dart';
import 'package:pigeon_planet/features/cart/model/cart_repository.dart';
import 'package:pigeon_planet/features/cart/model/datasources/cart_remote_datasource.dart';
import 'package:pigeon_planet/features/cart/model/order_item_model.dart';
import 'package:pigeon_planet/features/cart/model/order_model.dart';
import 'package:pigeon_planet/features/cart/viewmodel/cart_bloc.dart';
import 'package:pigeon_planet/features/payments/model/payment_request_model.dart';
import 'package:pigeon_planet/features/payments/model/payments_repository.dart';
import 'package:pigeon_planet/features/payments/viewmodel/payments_bloc.dart';

void main() {
  group('cart/order checkout and payment proof flow', () {
    test(
      'checks out cart, creates one payment request, uploads proof, and approves it',
      () async {
        final cartRepository = _FakeCartRepository();
        final paymentsRepository = _FakePaymentsRepository();
        final cartBloc = CartBloc(repository: cartRepository);
        final paymentsBloc = PaymentsBloc(repository: paymentsRepository);

        addTearDown(cartBloc.close);
        addTearDown(paymentsBloc.close);

        cartBloc.add(const CartStarted());
        await pumpEventQueue();
        expect(cartBloc.state.status, CartStatus.loaded);
        expect(cartBloc.state.cart!.items, isEmpty);

        cartBloc.add(const CartItemAdded(10, 2));
        await pumpEventQueue();
        expect(cartBloc.state.status, CartStatus.loaded);
        expect(cartBloc.state.cart!.items.single.assetId, 10);
        expect(cartBloc.state.cart!.items.single.quantity, 2);

        cartBloc.add(const CartCheckoutRequested());
        await pumpEventQueue();
        expect(cartBloc.state.status, CartStatus.checkedOut);
        expect(cartBloc.state.lastOrder!.status, 'pending');
        expect(cartBloc.state.lastOrder!.items.single.status, 'pending_seller');

        cartBloc.add(const SellerOrderItemsLoadRequested());
        await pumpEventQueue();
        expect(cartBloc.state.sellerOrderItems.single.status, 'pending_seller');

        cartBloc.add(
          OrderItemApproveRequested(_FakeCartRepository.orderItemId),
        );
        await pumpEventQueue(times: 3);
        expect(cartBloc.state.itemActioning, isFalse);
        expect(cartBloc.state.sellerOrderItems.single.status, 'approved');

        paymentsBloc.add(
          MarketPaymentCreateRequested(_FakeCartRepository.orderItemId),
        );
        await pumpEventQueue(times: 3);
        expect(paymentsRepository.createMarketCalls, 1);
        expect(
          paymentsBloc.state.requests.single.orderItemId,
          _FakeCartRepository.orderItemId,
        );
        expect(paymentsBloc.state.requests.single.status, 'pending');

        paymentsBloc.add(
          MarketPaymentCreateRequested(_FakeCartRepository.orderItemId),
        );
        await pumpEventQueue(times: 3);
        expect(paymentsRepository.createMarketCalls, 1);
        expect(paymentsBloc.state.reusedExistingRequest, isTrue);
        expect(paymentsBloc.state.requests.single.status, 'pending');

        final proofFile = PlatformFile(
          name: 'payment-proof.jpg',
          size: 2048,
          path: r'C:\tmp\payment-proof.jpg',
        );
        paymentsBloc.add(
          PaymentBuyerNoteUpdateRequested(
            paymentsBloc.state.requests.single.id,
            'Transferred manually',
            proofFile: proofFile,
          ),
        );
        await pumpEventQueue();
        expect(paymentsRepository.lastProofFile, proofFile);
        expect(
          paymentsBloc.state.requests.single.buyerNote,
          'Transferred manually',
        );
        expect(
          paymentsBloc.state.requests.single.paymentProofUrl,
          endsWith('payment-proof.jpg'),
        );

        paymentsBloc.add(
          PaymentApproveRequested(paymentsBloc.state.requests.single.id),
        );
        await pumpEventQueue();
        expect(paymentsBloc.state.requests.single.status, 'approved');
      },
    );
  });
}

class _FakeCartRepository implements CartRepository {
  static const orderItemId = 901;

  CartModel _cart = _cartWithItems(const []);
  OrderItemModel? _orderItem;
  OrderModel? _order;

  @override
  Future<Either<Failure, CartModel>> getCart() async => Right(_cart);

  @override
  Future<Either<Failure, CartModel>> addItem(int assetId, int quantity) async {
    _cart = _cartWithItems([
      CartItemModel(
        id: 501,
        assetId: assetId,
        title: 'Race bird',
        sellerId: 77,
        sellerNickname: 'Seller 77',
        quantity: quantity,
        unitPrice: 125,
        total: 125 * quantity.toDouble(),
      ),
    ]);
    return Right(_cart);
  }

  @override
  Future<Either<Failure, CartModel>> updateItem(
    int itemId,
    int quantity,
  ) async {
    return addItem(10, quantity);
  }

  @override
  Future<Either<Failure, void>> removeItem(int itemId) async {
    _cart = _cartWithItems(const []);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    _cart = _cartWithItems(const []);
    return const Right(null);
  }

  @override
  Future<Either<Failure, OrderModel>> checkout() async {
    _orderItem = _orderItemWithStatus('pending_seller');
    _order = _orderWithItem(_orderItem!, status: 'pending');
    _cart = _cartWithItems(const [], status: 'converted');
    return Right(_order!);
  }

  @override
  Future<Either<Failure, OrderModel>> createOrderFromItems(
    List<({int assetId, int quantity})> items,
  ) async {
    return checkout();
  }

  @override
  Future<Either<Failure, OrderPageResult>> getOrders({
    String? status,
    int page = 1,
  }) async {
    return Right((
      items: _order == null ? <OrderModel>[] : [_order!],
      hasMore: false,
    ));
  }

  @override
  Future<Either<Failure, OrderModel>> getOrderDetail(int id) async {
    return Right(_order!);
  }

  @override
  Future<Either<Failure, OrderItemPageResult>> getSellerOrderItems({
    int page = 1,
  }) async {
    return Right((
      items: _orderItem == null ? <OrderItemModel>[] : [_orderItem!],
      hasMore: false,
    ));
  }

  @override
  Future<Either<Failure, void>> approveOrderItem(int itemId) async {
    _orderItem = _orderItemWithStatus('approved');
    _order = _orderWithItem(_orderItem!, status: 'processing');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> rejectOrderItem(int itemId) async {
    _orderItem = _orderItemWithStatus('rejected');
    _order = _orderWithItem(_orderItem!, status: 'cancelled');
    return const Right(null);
  }

  static CartModel _cartWithItems(
    List<CartItemModel> items, {
    String status = 'active',
  }) => CartModel(
    id: 301,
    status: status,
    items: items,
    subtotal: items.fold<double>(0, (sum, item) => sum + item.total),
    itemsCount: items.length,
  );

  static OrderItemModel _orderItemWithStatus(String status) => OrderItemModel(
    id: orderItemId,
    orderId: 701,
    assetId: 10,
    title: 'Race bird',
    sellerId: 77,
    sellerNickname: 'Seller 77',
    quantity: 2,
    unitPrice: 125,
    grossTotal: 250,
    discountAmount: 0,
    cashbackRedeemedAmount: 0,
    cashbackEarnedAmount: 0,
    total: 250,
    status: status,
  );

  static OrderModel _orderWithItem(
    OrderItemModel item, {
    required String status,
  }) => OrderModel(
    id: 701,
    status: status,
    totalPrice: item.total,
    sellersInvolved: [item.sellerId],
    items: [item],
  );
}

class _FakePaymentsRepository implements PaymentsRepository {
  final List<PaymentRequestModel> _requests = [];
  int createMarketCalls = 0;
  PlatformFile? lastProofFile;

  @override
  Future<Either<Failure, List<PaymentRequestModel>>>
  getPaymentRequests() async {
    return Right(List.unmodifiable(_requests));
  }

  @override
  Future<Either<Failure, PaymentRequestModel>> createAuctionPaymentRequest(
    int auctionItemId, {
    String? buyerNote,
    PlatformFile? proofFile,
  }) async {
    return const Left(
      ValidationFailure('Auction payments are not in this flow.'),
    );
  }

  @override
  Future<Either<Failure, PaymentRequestModel>> createMarketPaymentRequest(
    int orderItemId, {
    String? buyerNote,
    PlatformFile? proofFile,
  }) async {
    createMarketCalls++;
    final request = _request(
      status: 'pending',
      orderItemId: orderItemId,
      buyerNote: buyerNote,
      proofUrl: proofFile == null ? null : '/media/${proofFile.name}',
    );
    _requests
      ..clear()
      ..add(request);
    return Right(request);
  }

  @override
  Future<Either<Failure, PaymentRequestModel>> updateBuyerNote(
    int requestId,
    String buyerNote, {
    PlatformFile? proofFile,
  }) async {
    lastProofFile = proofFile;
    final index = _requests.indexWhere((request) => request.id == requestId);
    final updated = _requests[index].copyWith(
      buyerNote: buyerNote,
      paymentProofUrl: proofFile == null ? null : '/media/${proofFile.name}',
    );
    _requests[index] = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, PaymentRequestModel>> approvePaymentRequest(
    int requestId,
  ) async {
    final index = _requests.indexWhere((request) => request.id == requestId);
    final updated = _requests[index].copyWith(status: 'approved');
    _requests[index] = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, PaymentRequestModel>> rejectPaymentRequest(
    int requestId, {
    String? sellerNote,
  }) async {
    final index = _requests.indexWhere((request) => request.id == requestId);
    final updated = _requests[index].copyWith(
      status: 'rejected',
      sellerNote: sellerNote,
    );
    _requests[index] = updated;
    return Right(updated);
  }

  PaymentRequestModel _request({
    required String status,
    required int orderItemId,
    String? buyerNote,
    String? proofUrl,
  }) => PaymentRequestModel(
    id: 801,
    status: status,
    type: 'market',
    amount: 250,
    buyerNote: buyerNote,
    orderItemId: orderItemId,
    assetId: 10,
    assetTitle: 'Race bird',
    assetCategory: 'bird',
    buyerProfileId: 33,
    sellerProfileId: 77,
    created: DateTime(2026, 6, 25),
    paymentProofUrl: proofUrl,
  );
}
