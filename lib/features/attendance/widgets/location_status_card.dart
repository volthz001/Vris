import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/mock_location_service.dart'; // LocationCheckResult

/// Kartu yang menampilkan status verifikasi lokasi secara visual:
/// - Memverifikasi (loading)
/// - Lokasi asli & dalam radius (hijau)
/// - Lokasi palsu terdeteksi (merah, alasan spesifik)
/// - Di luar radius kantor (kuning/oranye)
class LocationStatusCard extends StatelessWidget {
  final bool isChecking;
  final LocationCheckResult? result;

  const LocationStatusCard({super.key, required this.isChecking, this.result});

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return _buildContainer(
        color: AppColors.info,
        icon: Icons.satellite_alt_outlined,
        title: 'Memverifikasi lokasi...',
        subtitle: 'Mengecek GPS asli dan posisi terhadap kantor',
        animated: true,
      );
    }

    if (result == null) {
      return _buildContainer(
        color: AppColors.textMuted,
        icon: Icons.location_searching_rounded,
        title: 'Lokasi belum diverifikasi',
        subtitle: 'Tekan tombol absen untuk memulai verifikasi',
      );
    }

    if (result!.isMocked) {
      return _buildContainer(
        color: AppColors.danger,
        icon: Icons.gpp_bad_outlined,
        title: 'Lokasi palsu terdeteksi',
        subtitle: result!.rejectionReason,
      );
    }

    // No geofence check — SF bekerja di lapangan lintas wilayah, koordinat
    // dicatat sebagai audit trail tanpa validasi radius ke titik kantor.
    return _buildContainer(
      color: AppColors.success,
      icon: Icons.verified_outlined,
      title: 'Lokasi terverifikasi',
      subtitle:
          'GPS asli • Koordinat dicatat (${result!.position?.latitude.toStringAsFixed(5)}, '
          '${result!.position?.longitude.toStringAsFixed(5)})',
    );
  }

  Widget _buildContainer({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    bool animated = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (animated)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: color),
            )
          else
            Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.85),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
