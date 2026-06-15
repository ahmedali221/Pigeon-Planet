import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../cart_model.dart';
import '../order_model.dart';
import 'cart_remote_datasource.dart';

class RealCartRemoteDataSource implements CartRemoteDataSource {
  final DioClient _dio;

  const RealCartRemoteDataSource(this._dio);

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
}
