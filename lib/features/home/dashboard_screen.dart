import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../auth/data/auth_provider.dart';
import '../attendance/data/attendance_provider.dart';
import '../attendance/screens/attendance_screen.dart';
import '../kasbon/screens/kasbon_screen.dart';
import '../kpi/screens/kpi_screen.dart';
import '../messaging/screens/conversation_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final attendance = context.watch<AttendanceProvider>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo,', style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      user?.name ?? '-',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user?.initials ?? '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attendance.today?.hasCheckedIn == true
                              ? (attendance.today?.hasCheckedOut == true
                                  ? 'Absensi hari ini lengkap'
                                  : 'Sudah check-in hari ini')
                              : 'Belum absen hari ini',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Dilindungi deteksi lokasi palsu',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            minimumSize: const Size(0, 42),
                          ),
                          child: const Text('Buka absensi'),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified_user_rounded, color: Colors.white24, size: 56),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Menu', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _MenuTile(
                  icon: Icons.fingerprint_rounded,
                  label: 'Absensi',
                  color: AppColors.accent,
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const AttendanceScreen())),
                ),
                _MenuTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Kasbon',
                  color: AppColors.warning,
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const KasbonScreen())),
                ),
                _MenuTile(
                  icon: Icons.bar_chart_rounded,
                  label: 'KPI',
                  color: AppColors.info,
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const KpiScreen())),
                ),
                _MenuTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Pesan',
                  color: AppColors.primary,
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const ConversationListScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
