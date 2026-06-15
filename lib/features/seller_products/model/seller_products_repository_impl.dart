import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'datasources/seller_products_datasource.dart';
import 'seller_product_model.dart';
import 'seller_product_payload.dart';
import 'seller_products_repository.dart';

class SellerProductsRepositoryImpl implements SellerProductsRepository {
  final SellerProductsDataSource _dataSource;
  int? _cachedProfileId;

  SellerProductsRepositoryImpl(this._dataSource);

  Future<Either<Failure, int>> _getProfileId() async {
    if (_cachedProfileId != null) return Right(_cachedProfileId!);
    return _wrap(() async {
      _cachedProfileId = await _dataSource.getSellerProfileId();
      return _cachedProfileId!;
    });
  }

  @override
  Future<Either<Failure, List<SellerProductModel>>> getMyProducts({
    String? category,
    int page = 1,
  }) async {
    final profileResult = await _getProfileId();
    return profileResult.fold(
      Left.new,
      (profileId) => _wrap(() => _dataSource.getProducts(
            profileId: profileId,
            category: category,
            page: page,
          )),
    );
  }

  @override
  Future<Either<Failure, SellerProductModel>> createProduct(
          SellerProductPayload payload) =>
      _wrap(() => _dataSource.createProduct(payload.category, payload.toJson()));

  @override
  Future<Either<Failure, SellerProductModel>> updateProduct(
          String category, int id, SellerProductUpdatePayload payload) =>
      _wrap(() => _dataSource.updateProduct(category, id, payload.toJson()));

  @override
  Future<Either<Failure, void>> deleteProduct(String category, int id) =>
      _wrap(() => _dataSource.deleteProduct(category, id));

  Future<Either<Failure, T>> _wrap<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    if (e is ForbiddenException) return ForbiddenFailure(e.message);
    return ServerFailure(e.message);
  }
}
