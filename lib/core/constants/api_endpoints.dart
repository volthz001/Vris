// lib/core/constants/api_endpoints.dart
class ApiEndpoints {
  // ============================================================
  // AUTH
  // ============================================================
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String refresh = '/auth/refresh';

  // ============================================================
  // KPI
  // ============================================================
  static const String kpiDashboard = '/kpi/dashboard';

  // ============================================================
  // ATTENDANCE
  // ============================================================
  static const String attendanceToday = '/attendance/today';
  static const String attendanceCheckIn = '/attendance/check-in';
  static const String attendanceCheckOut = '/attendance/check-out';
  static const String attendanceHistory = '/attendance/history';
  static const String attendanceStatus = '/attendance/status';
  static const String attendanceIzin = '/attendance/izin';
  static const String attendanceSakit = '/attendance/sakit';

  // ============================================================
  // KASBON
  // ============================================================
  static const String kasbonList = '/kasbon';
  static const String kasbonCreate = '/kasbon';
  // approve & reject pakai path param: /kasbon/{id}/approve|reject
  // repository sudah build path-nya sendiri, cukup base path ini:
  static const String kasbonApprove = '/kasbon';
  static const String kasbonReject = '/kasbon';

  // ============================================================
  // MESSAGING
  // ============================================================
  static const String conversations = '/pesan/conversations';
  static const String messagesByConversation = '/pesan/conversation';
  static const String messagesSend = '/pesan/kirim';
  static const String messagesAction = '/pesan/action';
  static const String messagesUnreadCount = '/pesan/unread-count';
  static const String messagesMarkRead = '/pesan/read';
}
