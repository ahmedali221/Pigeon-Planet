import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../payment_request_model.dart';
import 'payments_remote_datasource.dart';

class RealPaymentsRemoteDataSource implements PaymentsRemoteDataSource {
  final DioClient _dio;

  const RealPaymentsRemoteDataSource(this._dio);

  PaymentRequestModel _parse(dynamic data) =>
      PaymentRequestModel.fromJson(data as Map<String, dynamic>);

  List<PaymentRequestModel> _parseList(dynamic data) {
    List<dynamic> items;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      throw const ServerException('Unexpected response format');
    }
    return items.map((e) => _parse(e)).toList();
  }

  @override
  Future<List<PaymentRequestModel>> getPaymentRequests() async {
    final response = await _dio.get(ApiConstants.paymentRequests);
    return _parseList(response.data);
  }

  @override
  Future<PaymentRequestModel> createAuctionPaymentRequest(
    int auctionItemId, {
    String? buyerNote,
  }) async {
    final payload = <String, dynamic>{
      'auction_item_id': auctionItemId,
      if (buyerNote != null && buyerNote.isNotEmpty) 'buyer_note': buyerNote,
    };
    final response = await _dio.post(
      ApiConstants.auctionPaymentRequest,
      data: payload,
    );
    return _parse(response.data);
  }

  @override
  Future<PaymentRequestModel> createMarketPaymentRequest(
    int orderItemId, {
    String? buyerNote,
  }) async {
    final payload = <String, dynamic>{
      'order_item_id': orderItemId,
      if (buyerNote != null && buyerNote.isNotEmpty) 'buyer_note': buyerNote,
    };
    final response = await _dio.post(
      ApiConstants.marketPaymentRequest,
      data: payload,
    );
    return _parse(response.data);
  }

  @override
  Future<PaymentRequestModel> updateBuyerNote(
    int requestId,
    String buyerNote,
  ) async {
    final response = await _dio.patch(
      ApiConstants.paymentRequestDetail(requestId),
      data: {'buyer_note': buyerNote},
    );
    return _parse(response.data);
  }

  @override
  Future<PaymentRequestModel> approvePaymentRequest(int requestId) async {
    final response = await _dio.post(
      ApiConstants.approvePaymentRequest(requestId),
    );
    return _parse(response.data);
  }

  @override
  Future<PaymentRequestModel> rejectPaymentRequest(
    int requestId, {
    String? sellerNote,
  }) async {
    final payload = <String, dynamic>{
      if (sellerNote != null && sellerNote.isNotEmpty) 'seller_note': sellerNote,
    };
    final response = await _dio.post(
      ApiConstants.rejectPaymentRequest(requestId),
      data: payload.isEmpty ? null : payload,
    );
    return _parse(response.data);
  }
}
