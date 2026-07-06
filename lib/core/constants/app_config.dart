// lib/core/constants/app_config.dart
class AppConfig {
  // Ganti dengan IP server Flask Anda
  static const String baseUrl =
      'https://web-production-a7fe5.up.railway.app/payroll/'; // Android Emulator
  // static const String baseUrl = 'http://localhost:5000'; // iOS Simulator

  static const Duration timeout = Duration(seconds: 30);
  static const String appName = 'VRIS - MCP HRIS';
  static const String appVersion = '1.0.0';
}
