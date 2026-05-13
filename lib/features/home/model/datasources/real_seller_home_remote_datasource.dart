import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../seller_home_summary.dart';
import 'seller_home_remote_datasource.dart';

class RealSellerHomeRemoteDataSource implements SellerHomeRemoteDataSource {
  final DioClient _dio;

  const RealSellerHomeRemoteDataSource(this._dio);

  @override
  Future<SellerHomeSummary?> fetchHomeSummary() async {
    try {
      final response = await _dio.get(ApiConstants.sellerHomeSummary);
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      return SellerHomeSummary.fromJson(data);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 400 || code == 403) return null;
      rethrow;
    }
  }
}
