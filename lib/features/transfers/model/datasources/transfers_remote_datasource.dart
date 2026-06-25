import '../../../home/model/seller_model.dart';
import '../ownership_transfer_model.dart';

abstract class TransfersRemoteDataSource {
  Future<List<OwnershipTransferModel>> getTransfers({int? assetId});
  Future<OwnershipTransferModel> createTransfer({
    required int assetId,
    required int toProfileId,
    String? note,
  });
  Future<List<SellerModel>> searchSellers(String query);
}
