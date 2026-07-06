// lib/features/attendance/data/attendance_repository.dart
import '../../../core/services/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/attendance_record.dart';

class AttendanceRepository {
  final _api = ApiClient.instance;

  /// POST /attendance/check-in
  /// Body: { "lat": double, "lng": double, "accuracy": double, "device_time": iso8601 }
  /// Server WAJIB cross-check geofence di sisi server juga (jangan percaya
  /// klien sepenuhnya) — lihat catatan kontrak API.
  Future<AttendanceRecord> checkIn({
    required double lat,
    required double lng,
    required double accuracy,
  }) async {
    final res = await _api.post(
      ApiEndpoints.attendanceCheckIn,
      data: {
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'device_time': DateTime.now().toIso8601String(),
      },
    );

    // ✅ Cek success dulu
    if (res['success'] == true) {
      return AttendanceRecord.fromJson(res['data']);
    } else {
      throw Exception(res['message'] ?? 'Gagal check-in');
    }
  }

  /// POST /attendance/check-out
  Future<AttendanceRecord> checkOut({
    required double lat,
    required double lng,
    required double accuracy,
  }) async {
    final res = await _api.post(
      ApiEndpoints.attendanceCheckOut,
      data: {
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'device_time': DateTime.now().toIso8601String(),
      },
    );

    // ✅ Cek success dulu
    if (res['success'] == true) {
      return AttendanceRecord.fromJson(res['data']);
    } else {
      throw Exception(res['message'] ?? 'Gagal check-out');
    }
  }

  /// GET /attendance/today
  Future<AttendanceRecord?> getToday() async {
    try {
      final res = await _api.get(ApiEndpoints.attendanceToday);

      // ✅ Cek success dan data ada
      if (res['success'] == true && res['data'] != null) {
        return AttendanceRecord.fromJson(res['data']);
      }
      return null;
    } catch (e) {
      // Kalau error (misal 404), return null
      return null;
    }
  }

  /// GET /attendance/history?month=&year=
  Future<List<AttendanceRecord>> getHistory({int? month, int? year}) async {
    try {
      // ✅ queryParams BUKAN query
      final res = await _api.get(
        ApiEndpoints.attendanceHistory,
        queryParams: {
          if (month != null) 'month': month.toString(), // ✅ harus String
          if (year != null) 'year': year.toString(), // ✅ harus String
        },
      );

      // ✅ Cek success
      if (res['success'] == true) {
        final list = (res['data'] as List?) ?? [];
        return list.map((e) => AttendanceRecord.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// GET /attendance/status - cek status absensi hari ini
  Future<Map<String, dynamic>> getStatus() async {
    try {
      final res = await _api.get('/attendance/status');
      if (res['success'] == true) {
        return res['data'] ?? {};
      }
      return {'hasCheckedIn': false, 'hasCheckedOut': false};
    } catch (e) {
      return {'hasCheckedIn': false, 'hasCheckedOut': false};
    }
  }

  /// POST /attendance/izin - ajukan izin
  Future<Map<String, dynamic>> submitIzin({
    required String keterangan,
    String? noSurat,
  }) async {
    final res = await _api.post(
      ApiEndpoints.attendanceIzin, // Tambahkan di ApiEndpoints
      data: {
        'keterangan': keterangan,
        if (noSurat != null) 'no_surat': noSurat,
      },
    );

    if (res['success'] == true) {
      return res;
    } else {
      throw Exception(res['message'] ?? 'Gagal mengajukan izin');
    }
  }

  /// POST /attendance/sakit - ajukan sakit
  Future<Map<String, dynamic>> submitSakit({
    required String keterangan,
    String? noSurat,
  }) async {
    final res = await _api.post(
      ApiEndpoints.attendanceSakit, // Tambahkan di ApiEndpoints
      data: {
        'keterangan': keterangan,
        if (noSurat != null) 'no_surat': noSurat,
      },
    );

    if (res['success'] == true) {
      return res;
    } else {
      throw Exception(res['message'] ?? 'Gagal mengajukan sakit');
    }
  }
}
