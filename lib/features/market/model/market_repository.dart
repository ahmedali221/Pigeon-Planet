import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../features/auctions/model/bird_summary_model.dart';
import 'product_model.dart';

abstract class MarketRepository {
  Future<Either<Failure, List<ProductModel>>> getProducts(
    String assetType, {
    int page = 1,
    String? query,
  });

  Future<Either<Failure, List<BirdSummaryModel>>> getBirds({
    int page = 1,
    String? query,
  });
}
