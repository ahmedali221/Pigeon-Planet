import '../referral_model.dart';

abstract class ReferralsRemoteDataSource {
  Future<ReferralCodeModel> createOrGetCode();
  Future<void> redeemCode(String code);
}
