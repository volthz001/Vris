// lib/features/kpi/data/kpi_provider.dart
import 'package:flutter/foundation.dart';
import '../data/kpi_repository.dart';
import '../models/kpi_summary.dart';

class KpiProvider extends ChangeNotifier {
  final _repo = KpiRepository();

  KpiSummary? summary;
  bool isLoading = false;
  String? errorMessage;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  String? selectedWok;

  Future<void> load({int? month, int? year, String? wok}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      summary = await _repo.getDashboard(
        month: month ?? selectedMonth,
        year: year ?? selectedYear,
        wok: wok ?? selectedWok,
      );

      if (summary != null) {
        selectedMonth = summary!.month;
        selectedYear = summary!.year;
        selectedWok = summary!.wok;
      }
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      // summary tetap null → screen tampilkan pesan error, bukan data palsu
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setFilter({int? month, int? year, String? wok}) {
    if (month != null) selectedMonth = month;
    if (year != null) selectedYear = year;
    if (wok != null) selectedWok = wok;
    load();
  }
}
