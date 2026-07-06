import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Wrapper di atas flutter_secure_storage khusus untuk data auth.
/// Token disimpan di Android Keystore (encrypted), bukan SharedPreferences,
/// supaya tidak gampang diambil walau device root.
class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
    required String name,
  }) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: accessToken);
    await _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken);
    await _storage.write(key: AppConstants.keyUserId, value: userId);
    await _storage.write(key: AppConstants.keyUserRole, value: role);
    await _storage.write(key: AppConstants.keyUserName, value: name);
  }

  Future<String?> get accessToken => _storage.read(key: AppConstants.keyAccessToken);
  Future<String?> get refreshToken => _storage.read(key: AppConstants.keyRefreshToken);
  Future<String?> get userId => _storage.read(key: AppConstants.keyUserId);
  Future<String?> get userRole => _storage.read(key: AppConstants.keyUserRole);
  Future<String?> get userName => _storage.read(key: AppConstants.keyUserName);

  Future<void> updateAccessToken(String token) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: token);
  }

  Future<bool> get hasSession async => (await accessToken) != null;

  Future<void> clearSession() async {
    await _storage.delete(key: AppConstants.keyAccessToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
    await _storage.delete(key: AppConstants.keyUserId);
    await _storage.delete(key: AppConstants.keyUserRole);
    await _storage.delete(key: AppConstants.keyUserName);
  }
}
