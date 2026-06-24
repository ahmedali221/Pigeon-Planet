import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../referral_model.dart';
import 'referrals_remote_datasource.dart';

class RealReferralsRemoteDataSource implements ReferralsRemoteDataSource {
  final DioClient _dio;

  RealReferralsRemoteDataSource(this._dio);

  @override
  Future<ReferralCodeModel> createOrGetCode() async {
    try {
      final response = await _dio.post(ApiConstants.referralCodes);
      return ReferralCodeModel.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل في إنشاء كود الإحالة');
    }
  }

  @override
  Future<void> redeemCode(String code) async {
    try {
      await _dio.post(ApiConstants.referralRedeem, data: {'code': code});
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل في استخدام كود الإحالة');
    }
  }
}
