import '../user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  });

  Future<UserModel> registerPersonal({
    required String phoneNumber,
    required String password,
    required String country,
    required String username,
    String? avatarPath,
  });

  Future<UserModel> registerProvider({
    required String phoneNumber,
    required String password,
    required String country,
    required String username,
    String? avatarPath,
  });

  Future<void> resendOtp({required String phoneNumber});

  Future<UserModel> switchProfile(String newProfile);

  Future<void> createSellerProfile();

  Future<UserModel?> getStoredUser();

  Future<void> logout();
}

// ─────────────────────────────────────────────
// Demo / Mock implementation — kept for OTP mock
// ─────────────────────────────────────────────
class DemoAuthRemoteDataSource implements AuthRemoteDataSource {
  static const _fakeDelay = Duration(milliseconds: 1200);

  @override
  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    await Future.delayed(_fakeDelay);
    if (phoneNumber.length >= 9 && password.length >= 6) {
      return UserModel(
        id: 1,
        phoneNumber: phoneNumber,
        profileType: 'Customer',
        accessToken: 'demo_access_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'demo_refresh_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
    throw DemoException('رقم الهاتف أو كلمة المرور غير صحيحة');
  }

  @override
  Future<UserModel> registerPersonal({
    required String phoneNumber,
    required String password,
    required String country,
    required String username,
    String? avatarPath,
  }) async {
    await Future.delayed(_fakeDelay);
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch,
      phoneNumber: phoneNumber,
      profileType: 'Customer',
      accessToken: 'demo_access_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'demo_refresh_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<UserModel> registerProvider({
    required String phoneNumber,
    required String password,
    required String country,
    required String username,
    String? avatarPath,
  }) async {
    await Future.delayed(_fakeDelay);
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch,
      phoneNumber: phoneNumber,
      profileType: 'Seller',
      accessToken: 'demo_access_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'demo_refresh_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<void> resendOtp({required String phoneNumber}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<UserModel> switchProfile(String newProfile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UserModel(
      id: 1,
      phoneNumber: '+201234567890',
      profileType: newProfile,
      accessToken: 'demo_access_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'demo_refresh_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<void> createSellerProfile() async {}

  @override
  Future<UserModel?> getStoredUser() async => null;

  @override
  Future<void> logout() async {}
}

class DemoException implements Exception {
  final String message;
  const DemoException(this.message);
  @override
  String toString() => message;
}
