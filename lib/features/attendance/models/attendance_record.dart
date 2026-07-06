class AttendanceRecord {
  final String id;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status; // hadir, terlambat, izin, sakit, alpha
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;

  AttendanceRecord({
    required this.id,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      checkInTime: json['check_in_time'] != null
          ? DateTime.tryParse(json['check_in_time'])
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.tryParse(json['check_out_time'])
          : null,
      status: json['status'] ?? 'alpha',
      checkInLat: (json['check_in_lat'] as num?)?.toDouble(),
      checkInLng: (json['check_in_lng'] as num?)?.toDouble(),
      checkOutLat: (json['check_out_lat'] as num?)?.toDouble(),
      checkOutLng: (json['check_out_lng'] as num?)?.toDouble(),
    );
  }

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;

  String get statusLabel {
    switch (status) {
      case 'hadir':
        return 'Hadir';
      case 'terlambat':
        return 'Terlambat';
      case 'izin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      default:
        return 'Alpha';
    }
  }
}
