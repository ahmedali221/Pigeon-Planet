import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> getProfile(String profileType);
  Future<Either<Failure, ProfileModel>> updateProfile(ProfileModel profile);
  Future<Either<Failure, void>> deleteProfile(ProfileModel profile);
}
