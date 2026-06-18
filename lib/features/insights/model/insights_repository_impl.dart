import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'datasources/insights_remote_datasource.dart';
import 'insights_repository.dart';
import 'seller_insights_model.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  final InsightsRemoteDataSource _datasource;

  const InsightsRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, SellerInsightsModel>> getSellerInsights() async {
    try {
      final data = await _datasource.getSellerInsights();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
