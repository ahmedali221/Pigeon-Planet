import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'referral_model.dart';

abstract class ReferralsRepository {
  Future<Either<Failure, ReferralCodeModel>> createOrGetCode();
  Future<Either<Failure, void>> redeemCode(String code);
}
