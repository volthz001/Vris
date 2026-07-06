import 'package:flutter/foundation.dart';
import '../data/kasbon_repository.dart';
import '../models/kasbon_request.dart';
import '../../../core/services/api_exception.dart';

class KasbonProvider extends ChangeNotifier {
  final _repo = KasbonRepository();

  List<KasbonRequest> items = [];
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> loadList() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      items = await _repo.getList();
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Gagal memuat data kasbon.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submit({required double amount, required String reason}) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      final created = await _repo.create(amount: amount, reason: reason);
      items.insert(0, created);
      isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isSubmitting = false;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Gagal mengajukan kasbon.';
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
