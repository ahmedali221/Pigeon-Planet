import 'package:file_picker/file_picker.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/cloudinary_service.dart';
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

  Future<String> _uploadProof(PlatformFile file) async {
    assert(file.path != null, 'PlatformFile must have a path');
    final url = await CloudinaryService.uploadPaymentProof(file.path!);
    if (url == null) throw const ServerException('Failed to upload payment proof');
    return url;
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
    PlatformFile? proofFile,
  }) async {
    assert(proofFile != null, 'payment_proof is required');
    final proofUrl = await _uploadProof(proofFile!);
    final response = await _dio.post(
      ApiConstants.auctionPaymentRequest,
      data: {
        'auction_item_id': auctionItemId,
        if (buyerNote != null && buyerNote.isNotEmpty) 'buyer_note': buyerNote,
        'payment_proof': proofUrl,
      },
    );
    return _parse(response.data);
  }

  @override
  Future<PaymentRequestModel> createMarketPaymentRequest(
    int orderItemId, {
    String? buyerNote,
    PlatformFile? proofFile,
  }) async {
    assert(proofFile != null, 'payment_proof is required');
    final proofUrl = await _uploadProof(proofFile!);
    final response = await _dio.post(
      ApiConstants.marketPaymentRequest,
      data: {
        'order_item_id': orderItemId,
        if (buyerNote != null && buyerNote.isNotEmpty) 'buyer_note': buyerNote,
        'payment_proof': proofUrl,
      },
    );
    return _parse(response.data);
  }

  @override
  Future<PaymentRequestModel> updateBuyerNote(
    int requestId,
    String buyerNote, {
    PlatformFile? proofFile,
  }) async {
    final data = <String, dynamic>{'buyer_note': buyerNote};
    if (proofFile != null) {
      data['payment_proof'] = await _uploadProof(proofFile);
    }
    final response = await _dio.patch(
      ApiConstants.paymentRequestDetail(requestId),
      data: data,
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
