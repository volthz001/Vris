/// Konstanta global aplikasi Vris.
/// Semua nilai yang sering berubah (base URL, endpoint) dipusatkan di sini
/// supaya gampang di-switch dari localhost ke staging/production.
library;

class AppConstants {
  AppConstants._();

  static const String appName = 'Vris';
  static const String appTagline = 'HRIS di genggaman, anti tipu lokasi';

  // ---------------------------------------------------------------------
  // BASE URL
  // Production: Railway. Kalau butuh testing ke localhost lagi, ganti
  // manual sementara ke salah satu di bawah (JANGAN commit perubahan itu):
  //   http://10.0.2.2:5000        (emulator Android)
  //   http://192.168.1.10:5000    (HP fisik via WiFi, ganti ke IP LAN kamu)
  // ---------------------------------------------------------------------
  static const String baseUrl = 'https://web-production-a7fe5.up.railway.app';

  static const String apiPrefix = '/api/v1';

  // ---------------------------------------------------------------------
  // SECURE STORAGE KEYS
  // ---------------------------------------------------------------------
  static const String keyAccessToken = 'vris_access_token';
  static const String keyRefreshToken = 'vris_refresh_token';
  static const String keyUserId = 'vris_user_id';
  static const String keyUserRole = 'vris_user_role';
  static const String keyUserName = 'vris_user_name';

  // ---------------------------------------------------------------------
  // ROLES (mengikuti RBAC 6-role MCP-HRIS)
  // ---------------------------------------------------------------------
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleHr = 'hr';
  static const String roleManager = 'manager';
  static const String roleSupervisor = 'supervisor';
  static const String roleEmployee = 'employee';

  // ---------------------------------------------------------------------
  // GEOFENCE: SENGAJA TIDAK ADA.
  // SF kerja di lapangan lintas WOK (JAKTIM s/d TANGERANG), bukan di satu
  // titik kantor tetap — geofence radius-dari-kantor tidak berlaku untuk
  // model kerja ini. Validasi anti-fake-GPS tetap jalan (lihat
  // mock_location_service.dart), cuma bukan berbasis jarak ke satu titik.
  // ---------------------------------------------------------------------

  // Jam window absensi
  static const String checkInStart = '07:00';
  static const String checkInEnd = '09:30';
  static const String checkOutStart = '16:00';
  static const String checkOutEnd = '21:00';
}
