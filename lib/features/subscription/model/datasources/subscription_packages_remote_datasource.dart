import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../subscription_package_model.dart';

abstract class SubscriptionPackagesRemoteDataSource {
  Future<List<PackageModel>> fetchPackages();
  Future<ActiveSellerPackageModel?> fetchActivePackage();
  Future<void> requestPackage(int packageId);
  Future<PendingSellerPackageModel?> fetchPendingPackage();
  Future<void> cancelPackage(int id);
}

class RealSubscriptionPackagesRemoteDataSource
    implements SubscriptionPackagesRemoteDataSource {
  final DioClient _dio;

  const RealSubscriptionPackagesRemoteDataSource(this._dio);

  @override
  Future<List<PackageModel>> fetchPackages() async {
    final response = await _dio.get(ApiConstants.packages);
    final data = response.data;
    final List<dynamic> raw = data is Map && data['results'] is List
        ? data['results'] as List<dynamic>
        : data is List
            ? data
            : [];
    return raw
        .whereType<Map>()
        .map((e) => PackageModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<ActiveSellerPackageModel?> fetchActivePackage() async {
    try {
      final response = await _dio.get(
        ApiConstants.mySellerPackages,
        queryParameters: {'active': 'true'},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ActiveSellerPackageModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      if (e.error is NotFoundException) return null;
      rethrow;
    }
  }

  @override
  Future<void> requestPackage(int packageId) async {
    await _dio.post(
      ApiConstants.mySellerPackages,
      data: {'package_id': packageId},
    );
  }

  @override
  Future<PendingSellerPackageModel?> fetchPendingPackage() async {
    try {
      final response = await _dio.get(
        ApiConstants.mySellerPackages,
        queryParameters: {'status': 'pending'},
      );
      final data = response.data;
      final List<dynamic> raw = data is Map && data['results'] is List
          ? data['results'] as List<dynamic>
          : data is List
              ? data
              : [];
      if (raw.isEmpty) return null;
      return PendingSellerPackageModel.fromJson(
        Map<String, dynamic>.from(raw.first as Map),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cancelPackage(int id) async {
    await _dio.post(ApiConstants.cancelSellerPackage(id));
  }
}
