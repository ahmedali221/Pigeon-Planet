import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'seller_product_model.dart';
import 'seller_product_payload.dart';

abstract class SellerProductsRepository {
  Future<Either<Failure, List<SellerProductModel>>> getMyProducts({
    String? category,
    int page = 1,
  });

  Future<Either<Failure, SellerProductModel>> createProduct(
      SellerProductPayload payload);

  Future<Either<Failure, SellerProductModel>> updateProduct(
      String category, int id, SellerProductUpdatePayload payload);

  Future<Either<Failure, void>> deleteProduct(String category, int id);
}
