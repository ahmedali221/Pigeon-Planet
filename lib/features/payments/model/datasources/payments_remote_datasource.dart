import 'package:file_picker/file_picker.dart';

import '../payment_request_model.dart';

abstract class PaymentsRemoteDataSource {
  Future<List<PaymentRequestModel>> getPaymentRequests();
  Future<PaymentRequestModel> createAuctionPaymentRequest(
    int auctionItemId, {
    String? buyerNote,
    PlatformFile? proofFile,
  });
  Future<PaymentRequestModel> createMarketPaymentRequest(
    int orderItemId, {
    String? buyerNote,
    PlatformFile? proofFile,
  });
  Future<PaymentRequestModel> updateBuyerNote(
    int requestId,
    String buyerNote, {
    PlatformFile? proofFile,
  });
  Future<PaymentRequestModel> approvePaymentRequest(int requestId);
  Future<PaymentRequestModel> rejectPaymentRequest(
    int requestId, {
    String? sellerNote,
  });
}
