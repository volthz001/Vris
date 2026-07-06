import '../../../core/services/api_client.dart';
import '../../../core/services/secure_storage_service.dart';
import '../models/app_user.dart';

class AuthRepository {
  final _storage = SecureStorageService.instance;

  Future<AppUser> login({
    required String email, // field ini dipakai sebagai username
    required String password,
  }) async {
    // Backend pakai field "username", bukan "email"
    final res = await ApiClient.instance.post(
      '/api/mobile/auth/login',
      data: {
        'username': email.trim(),
        'password': password,
      },
    );

    // Backend return 401/403 dengan field "error" — ApiClient sudah throw Exception
    // Kalau sampai sini berarti sukses
    final user = AppUser.fromJson(res['user'] as Map<String, dynamic>);

    await _storage.saveSession(
      accessToken: res['access_token'] as String,
      refreshToken: res['refresh_token'] as String,
      userId: user.id,
      role: user.role,
      name: user.name,
    );

    return user;
  }

  Future<AppUser?> getCurrentUser() async {
    final hasSession = await _storage.hasSession;
    if (!hasSession) return null;

    final token = await _storage.accessToken;
    if (token == null) return null;

    try {
      // Verifikasi token masih valid ke backend
      final res = await ApiClient.instance.get('/api/mobile/auth/me');
      return AppUser.fromJson(res['user'] as Map<String, dynamic>);
    } catch (_) {
      // Token expired atau revoked — paksa logout
      await _storage.clearSession();
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/api/mobile/auth/logout', data: {});
    } catch (_) {
      // Tetap clear local session meski server error
    }
    await _storage.clearSession();
  }
}
