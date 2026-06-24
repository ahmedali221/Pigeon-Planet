import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../cart_model.dart';
import '../order_item_model.dart';
import '../order_model.dart';
import 'cart_remote_datasource.dart';

class RealCartRemoteDataSource implements CartRemoteDataSource {
  final DioClient _dio;

  const RealCartRemoteDataSource(this._dio);

  ({List<T> items, bool hasMore}) _parsePage<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data == null) return (items: <T>[], hasMore: false);
    final items = data is Map
        ? (data['results'] as List<dynamic>? ?? [])
        : (data as List<dynamic>? ?? []);
    return (
      items: items.map((j) => fromJson(j as Map<String, dynamic>)).toList(),
      hasMore: data is Map && data['next'] != null,
    );
  }

  @override
  Future<CartModel> getCart() async {
    final response = await _dio.get(ApiConstants.cart);
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CartModel> addItem(int assetId, int quantity) async {
    final response = await _dio.post(
      ApiConstants.cartItems,
      data: {'asset_id': assetId, 'quantity': quantity},
    );
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CartModel> updateItem(int itemId, int quantity) async {
    final response = await _dio.patch(
      ApiConstants.cartItemDetail(itemId),
      data: {'quantity': quantity},
    );
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeItem(int itemId) async {
    await _dio.delete(ApiConstants.cartItemDetail(itemId));
  }

  @override
  Future<void> clearCart() async {
    await _dio.delete(ApiConstants.cartClear);
  }

  @override
  Future<OrderModel> checkout() async {
    final response = await _dio.post(ApiConstants.checkout, data: {});
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> createOrderFromItems(
    List<({int assetId, int quantity})> items,
  ) async {
    final response = await _dio.post(ApiConstants.orders, data: {
      'items': items
          .map((item) => {
                'asset_id': item.assetId,
                'quantity': item.quantity,
              })
          .toList(),
    });
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderPageResult> getOrders({String? status, int page = 1}) async {
    final params = <String, dynamic>{'page': page};
    if (status != null) params['status'] = status;
    final response = await _dio.get(ApiConstants.orders, queryParameters: params);
    return _parsePage(response.data, OrderModel.fromJson);
  }

  @override
  Future<OrderModel> getOrderDetail(int id) async {
    final response = await _dio.get(ApiConstants.orderDetail(id));
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderItemPageResult> getSellerOrderItems({int page = 1}) async {
    final response = await _dio.get(ApiConstants.orderItems, queryParameters: {'page': page});
    return _parsePage(response.data, OrderItemModel.fromJson);
  }

  @override
  Future<void> approveOrderItem(int itemId) async {
    await _dio.post(ApiConstants.approveOrderItem(itemId), data: {});
  }

  @override
  Future<void> rejectOrderItem(int itemId) async {
    await _dio.post(ApiConstants.rejectOrderItem(itemId), data: {});
  }
}
