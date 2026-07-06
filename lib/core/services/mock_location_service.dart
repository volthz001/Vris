import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Hasil pemeriksaan integritas lokasi.
///
/// CATATAN DESAIN (diputuskan bareng user): SF kerja di lapangan lintas
/// wilayah WOK, bukan di satu titik kantor tetap — jadi TIDAK ADA validasi
/// geofence/radius di sini. Yang divalidasi cuma keaslian GPS (anti fake-GPS),
/// bukan jaraknya ke titik mana pun. Koordinat tetap dikirim ke server untuk
/// dicatat sebagai audit trail (lihat api_mobile.py di backend).
class LocationCheckResult {
  final bool isValid;
  final bool isMocked;
  final Position? position;
  final String? errorMessage;

  const LocationCheckResult({
    required this.isValid,
    required this.isMocked,
    this.position,
    this.errorMessage,
  });

  factory LocationCheckResult.error(String message) => LocationCheckResult(
        isValid: false,
        isMocked: false,
        errorMessage: message,
      );

  String get rejectionReason {
    if (errorMessage != null) return errorMessage!;
    if (isMocked) {
      return 'Lokasi palsu terdeteksi. Nonaktifkan aplikasi fake GPS / mock '
          'location sebelum melakukan absensi.';
    }
    return 'Lokasi tidak valid.';
  }
}

/// Service deteksi fake GPS / mock location sebelum absensi diizinkan.
///
/// LAPISAN DETEKSI:
/// 1. Position.isMocked (flag bawaan Android `ACCESS_MOCK_LOCATION` /
///    developer-option "Allow mock locations").
/// 2. Sanity check akurasi & kecepatan tidak wajar (indikasi GPS spoofing
///    app yang kurang canggih biasanya kasih akurasi sempurna/0).
///
/// Server (`api_mobile.py`) mengulang cek akurasi ini secara independen,
/// jadi validasi ini tidak bisa dilewati cuma dengan hit API langsung
/// tanpa lewat app.
///
/// CATATAN PENTING: `isMocked` HANYA reliable di Android. Di iOS, Apple
/// tidak menyediakan flag setara — efektif untuk kebutuhan Android-only.
class MockLocationService {
  MockLocationService._();
  static final MockLocationService instance = MockLocationService._();

  Future<bool> ensurePermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      final opened = await openAppSettings();
      return opened;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    return true;
  }

  /// Ambil posisi terkini lalu jalankan validasi anti-fake-GPS.
  /// TIDAK ada parameter geofence — lihat catatan desain di atas.
  Future<LocationCheckResult> getValidatedPosition() async {
    final hasPermission = await ensurePermission();
    if (!hasPermission) {
      return LocationCheckResult.error(
        'Izin lokasi diperlukan untuk absensi. Aktifkan izin lokasi di pengaturan.',
      );
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
    } catch (e) {
      return LocationCheckResult.error(
        'Gagal mendapatkan lokasi: ${e.toString()}. Pastikan GPS aktif dan '
        'berada di area terbuka.',
      );
    }

    // --- LAPISAN 1: flag mock location bawaan platform (Android) ---
    final bool mockFlag = position.isMocked;

    // --- LAPISAN 2: heuristik tambahan untuk app fake-GPS yang kurang rapi ---
    final bool suspiciousAccuracy = _hasSuspiciousAccuracy(position);

    final bool isMocked = mockFlag || suspiciousAccuracy;

    return LocationCheckResult(
      isValid: !isMocked,
      isMocked: isMocked,
      position: position,
    );
  }

  /// Heuristik sederhana: akurasi 0.0 atau kecepatan tidak wajar kerap
  /// muncul pada aplikasi fake-GPS murahan yang tidak mensimulasikan noise
  /// sensor GPS asli. Ini bukan bukti mutlak, hanya sinyal tambahan yang
  /// dikombinasikan dengan flag isMocked. Server memvalidasi ulang hal yang
  /// sama secara independen.
  bool _hasSuspiciousAccuracy(Position position) {
    if (position.accuracy <= 0.0) return true;
    if (position.speed < 0) return true;

    // Kecepatan instan tidak wajar (>120 m/s ~ 432 km/jam) untuk konteks
    // absensi pejalan kaki/kendaraan normal adalah red flag.
    if (position.speed > 120) return true;

    return false;
  }
}
