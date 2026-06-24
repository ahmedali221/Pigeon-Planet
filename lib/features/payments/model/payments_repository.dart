import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/error/failures.dart';
import 'payment_request_model.dart';

abstract class PaymentsRepository {
  Future<Either<Failure, List<PaymentRequestModel>>> getPaymentRequests();
  Future<Either<Failure, PaymentRequestModel>> createAuctionPaymentRequest(
    int auctionItemId, {
    String? buyerNote,
    PlatformFile? proofFile,
  });
  Future<Either<Failure, PaymentRequestModel>> createMarketPaymentRequest(
    int orderItemId, {
    String? buyerNote,
    PlatformFile? proofFile,
  });
  Future<Either<Failure, PaymentRequestModel>> updateBuyerNote(
    int requestId,
    String buyerNote, {
    PlatformFile? proofFile,
  });
  Future<Either<Failure, PaymentRequestModel>> approvePaymentRequest(
    int requestId,
  );
  Future<Either<Failure, PaymentRequestModel>> rejectPaymentRequest(
    int requestId, {
    String? sellerNote,
  });
}
