import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/token_storage.dart';
import '../user_model.dart';
import 'auth_remote_datasource.dart';

class RealAuthRemoteDataSource implements AuthRemoteDataSource {
  final DioClient _dio;
  final TokenStorage _tokenStorage;

  const RealAuthRemoteDataSource(this._dio, this._tokenStorage);

  @override
  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'phone_number': phoneNumber, 'password': password},
    );

    final access = response.data['access'] as String;
    final refresh = response.data['refresh'] as String;

    await _tokenStorage.saveTokens(access: access, refresh: refresh);

    final payload = DioClient.decodeJwtPayload(access);
    final userId = payload['user_id'] as int? ?? 0;
    final profileType = payload['profile'] as String? ?? 'Customer';

    return UserModel(
      id: userId,
      phoneNumber: phoneNumber,
      profileType: profileType,
      accessToken: access,
      refreshToken: refresh,
    );
  }

  @override
  Future<UserModel> registerPersonal({
    required String phoneNumber,
    required String password,
    required String country,
  }) async {
    await _dio.post(
      ApiConstants.registerCustomer,
      data: {
        'username': phoneNumber,
        'phone_number': phoneNumber,
        'password': password,
        'customer_profile': {
          'country': _toCountryCode(country),
          'currency': _toCurrency(country),
        },
      },
    );
    // Backend returns 201 with message only — login to get tokens
    return login(phoneNumber: phoneNumber, password: password);
  }

  @override
  Future<UserModel> registerProvider({
    required String phoneNumber,
    required String password,
    required String country,
  }) async {
    // Register as customer first (no seller endpoint exists)
    await _dio.post(
      ApiConstants.registerCustomer,
      data: {
        'username': phoneNumber,
        'phone_number': phoneNumber,
        'password': password,
        'customer_profile': {
          'country': _toCountryCode(country),
          'currency': _toCurrency(country),
        },
      },
    );
    // Login then switch to Seller profile
    await login(phoneNumber: phoneNumber, password: password);
    return switchProfile('Seller');
  }

  @override
  Future<void> resendOtp({required String phoneNumber}) async {
    // OTP endpoint not yet implemented on backend — no-op
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<UserModel> switchProfile(String newProfile) async {
    final response = await _dio.post(
      ApiConstants.switchProfile,
      data: {'new_profile': newProfile},
    );

    final access = response.data['access'] as String;
    final refresh = response.data['refresh'] as String;
    await _tokenStorage.saveTokens(access: access, refresh: refresh);

    final payload = DioClient.decodeJwtPayload(access);
    final userId = payload['user_id'] as int? ?? 0;
    final profileType = response.data['profile'] as String? ?? newProfile;

    return UserModel(
      id: userId,
      phoneNumber: '',
      profileType: profileType,
      accessToken: access,
      refreshToken: refresh,
    );
  }

  @override
  Future<UserModel?> getStoredUser() async {
    final access = await _tokenStorage.getAccessToken();
    final refresh = await _tokenStorage.getRefreshToken();
    if (access == null || refresh == null) return null;

    final payload = DioClient.decodeJwtPayload(access);
    final userId = payload['user_id'] as int?;
    if (userId == null) return null;

    final exp = payload['exp'] as int?;
    if (exp != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      if (expiry.isBefore(DateTime.now())) return null;
    }

    return UserModel(
      id: userId,
      phoneNumber: '',
      profileType: payload['profile'] as String? ?? 'Customer',
      accessToken: access,
      refreshToken: refresh,
    );
  }

  // Maps country name/code → ISO 2-letter code the backend expects
  String _toCountryCode(String country) {
    const map = {
      'مصر': 'EG', 'egypt': 'EG',
      'السعودية': 'SA', 'saudi': 'SA',
      'الإمارات': 'AE', 'uae': 'AE',
      'الكويت': 'KW', 'kuwait': 'KW',
      'قطر': 'QA', 'qatar': 'QA',
      'البحرين': 'BH', 'bahrain': 'BH',
      'عمان': 'OM', 'oman': 'OM',
      'الأردن': 'JO', 'jordan': 'JO',
    };
    final key = country.toLowerCase().trim();
    return map[key] ?? map[country] ?? 'EG';
  }

  String _toCurrency(String country) {
    const map = {
      'EG': 'EGP', 'SA': 'SAR', 'AE': 'AED',
      'KW': 'KWD', 'QA': 'QAR', 'BH': 'BHD',
      'OM': 'OMR', 'JO': 'JOD',
    };
    return map[_toCountryCode(country)] ?? 'EGP';
  }
}
