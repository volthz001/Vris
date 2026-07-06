// lib/features/attendance/providers/attendance_provider.dart
import 'package:flutter/foundation.dart';
import '../data/attendance_repository.dart';
import '../models/attendance_record.dart';

enum AttendanceAction { checkIn, checkOut }

class AttendanceProvider extends ChangeNotifier {
  final _repo = AttendanceRepository();

  AttendanceRecord? _today;
  List<AttendanceRecord> _history = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _lastError;
  DateTime? _lastLocationCheck;

  // Getters
  AttendanceRecord? get today => _today;
  List<AttendanceRecord> get history => _history;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get lastError => _lastError;
  DateTime? get lastLocationCheck => _lastLocationCheck;
  String get processingLabel => _isProcessing ? 'Memproses...' : '';

  bool get hasCheckedIn => _today?.checkInTime != null;
  bool get hasCheckedOut => _today?.checkOutTime != null;
  bool get isPresent => hasCheckedIn && hasCheckedOut;

  Future<void> loadToday() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _today = await _repo.getToday();
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory({int? month, int? year}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _history = await _repo.getHistory(
        month: month ?? DateTime.now().month,
        year: year ?? DateTime.now().year,
      );
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> performCheckIn({
    required double lat,
    required double lng,
    required double accuracy,
  }) async {
    _isProcessing = true;
    _lastError = null;
    _lastLocationCheck = DateTime.now();
    notifyListeners();

    try {
      _today = await _repo.checkIn(
        lat: lat,
        lng: lng,
        accuracy: accuracy,
      );
      return true;
    } catch (e) {
      _lastError = e.toString();
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<bool> performCheckOut({
    required double lat,
    required double lng,
    required double accuracy,
  }) async {
    _isProcessing = true;
    _lastError = null;
    _lastLocationCheck = DateTime.now();
    notifyListeners();

    try {
      _today = await _repo.checkOut(
        lat: lat,
        lng: lng,
        accuracy: accuracy,
      );
      return true;
    } catch (e) {
      _lastError = e.toString();
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadToday();
    await loadHistory();
  }

  void reset() {
    _today = null;
    _history = [];
    _lastError = null;
    _isProcessing = false;
    notifyListeners();
  }
}
