import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: accessTokenKey, value: token);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: refreshTokenKey, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: accessTokenKey);

    await _storage.delete(key: refreshTokenKey);
  }
}
