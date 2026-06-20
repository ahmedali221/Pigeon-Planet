import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> getProfile(String profileType);
  Future<Either<Failure, List<ProfileModel>>> fetchAllSellerProfiles();
  Future<Either<Failure, void>> createRoom({
    required String nickname,
    required String description,
    required String country,
    required String currency,
  });
  Future<Either<Failure, ProfileModel>> updateProfile(ProfileModel profile);
  Future<Either<Failure, void>> deleteProfile(ProfileModel profile);
}
