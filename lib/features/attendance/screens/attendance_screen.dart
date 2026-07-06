// lib/features/attendance/screens/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/attendance_provider.dart';

String _fmtTime(DateTime dt) => DateFormat('HH:mm').format(dt);

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final hasCheckedIn = provider.hasCheckedIn;
          final hasCheckedOut = provider.hasCheckedOut;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Status Hari Ini'),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: hasCheckedIn ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                hasCheckedIn ? 'Hadir' : 'Belum Absen',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        if (hasCheckedIn) ...[
                          _infoRow(
                            'Check-in',
                            provider.today?.checkInTime != null
                                ? _fmtTime(provider.today!.checkInTime!)
                                : '-',
                          ),
                          if (hasCheckedOut)
                            _infoRow(
                              'Check-out',
                              provider.today?.checkOutTime != null
                                  ? _fmtTime(provider.today!.checkOutTime!)
                                  : '-',
                            ),
                        ],
                        if (provider.lastError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              provider.lastError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (!hasCheckedIn)
                  _buildButton(
                    label: 'Check-in',
                    icon: Icons.login,
                    color: Colors.blue,
                    onPressed: provider.isProcessing
                        ? null
                        : () => _simulateCheckIn(context),
                  ),
                if (hasCheckedIn && !hasCheckedOut)
                  _buildButton(
                    label: 'Check-out',
                    icon: Icons.logout,
                    color: Colors.orange,
                    onPressed: provider.isProcessing
                        ? null
                        : () => _simulateCheckOut(context),
                  ),
                const Spacer(),
                if (provider.isProcessing)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Memproses...'),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _simulateCheckIn(BuildContext context) async {
    final provider = context.read<AttendanceProvider>();
    final success = await provider.performCheckIn(
      lat: -6.2088,
      lng: 106.8456,
      accuracy: 10.0,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            success ? 'Check-in berhasil!' : provider.lastError ?? 'Gagal'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _simulateCheckOut(BuildContext context) async {
    final provider = context.read<AttendanceProvider>();
    final success = await provider.performCheckOut(
      lat: -6.2088,
      lng: 106.8456,
      accuracy: 10.0,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            success ? 'Check-out berhasil!' : provider.lastError ?? 'Gagal'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
