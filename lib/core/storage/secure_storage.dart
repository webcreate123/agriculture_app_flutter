import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorage {
  final FlutterSecureStorage _secureStorage;

  SecureStorage({
    required FlutterSecureStorage secureStorage,
  }) : _secureStorage = secureStorage;

  Future<void> setAccessToken(String token) async {
    await _secureStorage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> setUserId(String userId) async {
    await _secureStorage.write(key: AppConstants.userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: AppConstants.userIdKey);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
} 