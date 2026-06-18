import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../seller_insights_model.dart';

abstract class InsightsRemoteDataSource {
  Future<SellerInsightsModel> getSellerInsights();
}

class RealInsightsRemoteDataSource implements InsightsRemoteDataSource {
  final DioClient _dio;

  const RealInsightsRemoteDataSource(this._dio);

  @override
  Future<SellerInsightsModel> getSellerInsights() async {
    final response = await _dio.get(ApiConstants.insightsSellerHome);
    return SellerInsightsModel.fromJson(
        response.data as Map<String, dynamic>);
  }
}
