class KasbonRequest {
  final String id;
  final double amount;
  final String reason;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final String? approverName;
  final String? rejectionNote;

  KasbonRequest({
    required this.id,
    required this.amount,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.approverName,
    this.rejectionNote,
  });

  factory KasbonRequest.fromJson(Map<String, dynamic> json) {
    return KasbonRequest(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      reason: json['reason'] ?? json['keterangan'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      approverName: json['approver_name'],
      rejectionNote: json['rejection_note'],
    );
  }

  String get statusLabel {
    switch (status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }
}
