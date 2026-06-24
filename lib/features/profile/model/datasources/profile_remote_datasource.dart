import '../profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String profileType);
  Future<List<ProfileModel>> fetchAllSellerProfiles();
  Future<void> createRoom({
    required String nickname,
    required String country,
    required String currency,
  });
  Future<ProfileModel> updateProfile(ProfileModel profile);
  Future<void> deleteProfile(ProfileModel profile);
}
