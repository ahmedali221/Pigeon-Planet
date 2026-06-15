import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _countryKey = 'customer_country';
  static const _currencyKey = 'customer_currency';

  final FlutterSecureStorage _storage;

  TokenStorage() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: access),
      _storage.write(key: _refreshKey, value: refresh),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
    ]);
  }

  Future<bool> hasTokens() async {
    final token = await _storage.read(key: _accessKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> saveCustomerMeta({
    required String country,
    required String currency,
  }) async {
    await Future.wait([
      _storage.write(key: _countryKey, value: country),
      _storage.write(key: _currencyKey, value: currency),
    ]);
  }

  Future<({String country, String currency})?> getCustomerMeta() async {
    final country = await _storage.read(key: _countryKey);
    final currency = await _storage.read(key: _currencyKey);
    if (country == null || currency == null) return null;
    return (country: country, currency: currency);
  }

  Future<void> clearCustomerMeta() async {
    await Future.wait([
      _storage.delete(key: _countryKey),
      _storage.delete(key: _currencyKey),
    ]);
  }
}
