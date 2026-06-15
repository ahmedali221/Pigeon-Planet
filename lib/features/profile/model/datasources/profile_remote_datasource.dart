import '../profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String profileType);
  Future<ProfileModel> updateProfile(ProfileModel profile);
  Future<void> deleteProfile(ProfileModel profile);
}
