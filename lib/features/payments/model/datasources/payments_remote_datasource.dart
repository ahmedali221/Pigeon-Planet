import '../payment_request_model.dart';

abstract class PaymentsRemoteDataSource {
  Future<List<PaymentRequestModel>> getPaymentRequests();
  Future<PaymentRequestModel> createAuctionPaymentRequest(
    int auctionItemId, {
    String? buyerNote,
  });
  Future<PaymentRequestModel> createMarketPaymentRequest(
    int orderItemId, {
    String? buyerNote,
  });
  Future<PaymentRequestModel> updateBuyerNote(int requestId, String buyerNote);
  Future<PaymentRequestModel> approvePaymentRequest(int requestId);
  Future<PaymentRequestModel> rejectPaymentRequest(
    int requestId, {
    String? sellerNote,
  });
}
