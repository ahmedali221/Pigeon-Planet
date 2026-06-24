import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/cloudinary_service.dart';
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
    final avatarUrl = _avatarUrlFrom(payload);

    if (profileType == 'Manager') {
      throw const ForbiddenException('هذا التطبيق مخصص للمشترين والبائعين فقط');
    }

    return UserModel(
      id: userId,
      phoneNumber: phoneNumber,
      profileType: profileType,
      accessToken: access,
      refreshToken: refresh,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<UserModel> registerPersonal({
    required String phoneNumber,
    required String password,
    required String country,
    required String username,
    String? avatarPath,
  }) async {
    final countryCode = _toCountryCode(country);
    final currency = _toCurrency(country);
    await _dio.post(
      ApiConstants.registerCustomer,
      data: await _buildRegisterBody(
        username: username,
        phoneNumber: phoneNumber,
        password: password,
        countryCode: countryCode,
        currency: currency,
        avatarPath: avatarPath,
      ),
    );
    await _tokenStorage.saveCustomerMeta(
      country: countryCode,
      currency: currency,
    );
    return login(phoneNumber: phoneNumber, password: password);
  }

  @override
  Future<UserModel> registerProvider({
    required String phoneNumber,
    required String password,
    required String country,
    required String username,
    String? avatarPath,
  }) async {
    final countryCode = _toCountryCode(country);
    final currency = _toCurrency(country);
    await _dio.post(
      ApiConstants.registerCustomer,
      data: await _buildRegisterBody(
        username: username,
        phoneNumber: phoneNumber,
        password: password,
        countryCode: countryCode,
        currency: currency,
        avatarPath: avatarPath,
      ),
    );
    await _tokenStorage.saveCustomerMeta(
      country: countryCode,
      currency: currency,
    );
    await login(phoneNumber: phoneNumber, password: password);
    await createSellerProfile();
    return switchProfile('Seller');
  }

  Future<Map<String, dynamic>> _buildRegisterBody({
    required String username,
    required String phoneNumber,
    required String password,
    required String countryCode,
    required String currency,
    String? avatarPath,
  }) async {
    String? avatarUrl;
    if (avatarPath != null) {
      avatarUrl = await CloudinaryService.uploadAvatar(avatarPath, username);
    }
    return {
      'username': username,
      'phone_number': phoneNumber,
      'password': password,
      'customer_profile': {
        'country': countryCode,
        'currency': currency,
        ...?avatarUrl != null ? {'avatar_url': avatarUrl} : null,
      },
    };
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
    final avatarUrl = _avatarUrlFrom(payload);

    return UserModel(
      id: userId,
      phoneNumber: '',
      profileType: profileType,
      accessToken: access,
      refreshToken: refresh,
      avatarUrl: avatarUrl,
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

    final storedProfileType = payload['profile'] as String? ?? 'Customer';
    if (storedProfileType == 'Manager') return null;

    return UserModel(
      id: userId,
      phoneNumber: '',
      profileType: storedProfileType,
      accessToken: access,
      refreshToken: refresh,
      avatarUrl: _avatarUrlFrom(payload),
    );
  }

  @override
  Future<UserModel> switchProfileById(int profileId) async {
    final response = await _dio.post(
      ApiConstants.switchProfile,
      data: {'profile_id': profileId},
    );
    final access = response.data['access'] as String;
    final refresh = response.data['refresh'] as String;
    await _tokenStorage.saveTokens(access: access, refresh: refresh);
    final payload = DioClient.decodeJwtPayload(access);
    final userId = payload['user_id'] as int? ?? 0;
    final profileType = response.data['profile'] as String? ?? 'Seller';
    final avatarUrl = _avatarUrlFrom(payload);
    return UserModel(
      id: userId,
      phoneNumber: '',
      profileType: profileType,
      accessToken: access,
      refreshToken: refresh,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<List<int>> fetchMySellerProfileIds() async {
    final response = await _dio.get(ApiConstants.mySellers);
    final data = response.data;
    final List list;
    if (data is Map && data.containsKey('results')) {
      list = data['results'] as List;
    } else if (data is List) {
      list = data;
    } else {
      return [];
    }
    return list.map((e) => (e as Map)['id'] as int).toList();
  }

  @override
  Future<void> createSellerProfile() async {
    var meta = await _tokenStorage.getCustomerMeta();

    if (meta == null) {
      // Fallback: fetch customer profile from backend
      final response = await _dio.get(ApiConstants.myCustomers);
      final data = response.data;
      Map<String, dynamic> profile = {};
      if (data is Map && data.containsKey('results')) {
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          profile = Map<String, dynamic>.from(results.first as Map);
        }
      } else if (data is List && data.isNotEmpty) {
        profile = Map<String, dynamic>.from(data.first as Map);
      } else if (data is Map) {
        profile = Map<String, dynamic>.from(data);
      }
      final country = profile['country'] as String? ?? 'EG';
      final currency = profile['currency'] as String? ?? 'EGP';
      meta = (country: country, currency: currency);
      await _tokenStorage.saveCustomerMeta(
        country: country,
        currency: currency,
      );
    }

    try {
      await _dio.post(
        ApiConstants.mySellers,
        data: {'country': meta.country, 'currency': meta.currency},
      );
    } on DioException catch (e) {
      // 400 = "Profile already exists" — not an error, proceed to switch
      if (e.response?.statusCode == 400) return;
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
    await _tokenStorage.clearCustomerMeta();
  }

  // Maps country name/code → ISO 2-letter code the backend expects
  String _toCountryCode(String country) {
    const map = {
      'مصر': 'EG',
      'السعودية': 'SA',
      'الإمارات': 'AE',
      'الكويت': 'KW',
      'قطر': 'QA',
      'البحرين': 'BH',
      'عمان': 'OM',
      'الأردن': 'JO',
      'العراق': 'IQ',
      'لبنان': 'LB',
      'سوريا': 'SY',
      'ليبيا': 'LY',
      'تونس': 'TN',
      'المغرب': 'MA',
      'الجزائر': 'DZ',
      'السودان': 'SD',
      'اليمن': 'YE',
      'فلسطين': 'PS',
      'egypt': 'EG',
      'saudi': 'SA',
      'uae': 'AE',
      'kuwait': 'KW',
      'qatar': 'QA',
      'bahrain': 'BH',
      'oman': 'OM',
      'jordan': 'JO',
      'iraq': 'IQ',
      'lebanon': 'LB',
      'syria': 'SY',
      'libya': 'LY',
      'tunisia': 'TN',
      'morocco': 'MA',
      'algeria': 'DZ',
      'sudan': 'SD',
      'yemen': 'YE',
      'palestine': 'PS',
    };
    final key = country.toLowerCase().trim();
    return map[country] ?? map[key] ?? 'EG';
  }

  String _toCurrency(String country) {
    const map = {
      'EG': 'EGP',
      'SA': 'SAR',
      'AE': 'AED',
      'KW': 'KWD',
      'QA': 'QAR',
      'BH': 'BHD',
      'OM': 'OMR',
      'JO': 'JOD',
      'IQ': 'IQD',
      'LB': 'LBP',
      'SY': 'SYP',
      'LY': 'LYD',
      'TN': 'TND',
      'MA': 'MAD',
      'DZ': 'DZD',
      'SD': 'SDG',
      'YE': 'YER',
      'PS': 'ILS',
    };
    return map[_toCountryCode(country)] ?? 'EGP';
  }

  String? _avatarUrlFrom(Map<String, dynamic> payload) {
    final value = payload['avatar_url'] as String?;
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }
}
