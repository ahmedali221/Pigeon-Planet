import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../electronic_clock_model.dart';
import 'clocks_remote_datasource.dart';

class RealClocksRemoteDataSource implements ClocksRemoteDataSource {
  final DioClient _dio;

  RealClocksRemoteDataSource(this._dio);

  List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final List<dynamic> items;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      items = [];
    }
    return items.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ElectronicClockModel>> getClocks({
    String? search,
    bool inStockOnly = false,
  }) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (inStockOnly) params['in_stock'] = 'true';
    final response = await _dio.get(ApiConstants.clocks, queryParameters: params);
    return _parseList(response.data, ElectronicClockModel.fromJson);
  }

  @override
  Future<ElectronicClockModel> getClockDetail(int id) async {
    final response = await _dio.get(ApiConstants.clockDetail(id));
    return ElectronicClockModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ClockOrderModel> placeOrder({
    required int clockId,
    required int quantity,
    String note = '',
  }) async {
    final response = await _dio.post(
      ApiConstants.clockOrders,
      data: {
        'clock': clockId,
        'quantity': quantity,
        if (note.isNotEmpty) 'buyer_note': note,
      },
    );
    return ClockOrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ClockOrderModel> submitPaymentProof({
    required int orderId,
    required String proofUrl,
    String note = '',
  }) async {
    final response = await _dio.post(
      ApiConstants.clockOrderPay(orderId),
      data: {
        'payment_proof': proofUrl,
        if (note.isNotEmpty) 'note': note,
      },
    );
    return ClockOrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ClockOrderModel>> getMyOrders() async {
    final response = await _dio.get(ApiConstants.clockOrders);
    return _parseList(response.data, ClockOrderModel.fromJson);
  }
}
