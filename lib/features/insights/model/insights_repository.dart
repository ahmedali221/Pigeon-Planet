import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'seller_insights_model.dart';

abstract class InsightsRepository {
  Future<Either<Failure, SellerInsightsModel>> getSellerInsights();
}
