import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../home/model/seller_model.dart';
import 'ownership_transfer_model.dart';

abstract class TransfersRepository {
  Future<Either<Failure, List<OwnershipTransferModel>>> getTransfers({
    int? assetId,
  });
  Future<Either<Failure, OwnershipTransferModel>> createTransfer({
    required int assetId,
    required int toProfileId,
    String? note,
  });
  Future<Either<Failure, List<SellerModel>>> searchSellers(String query);
}
