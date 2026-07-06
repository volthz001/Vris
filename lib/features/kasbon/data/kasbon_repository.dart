import '../../../core/services/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/kasbon_request.dart';

class KasbonRepository {
  final _api = ApiClient.instance;

  /// GET /kasbon — riwayat kasbon milik user (atau semua, jika role approver)
  Future<List<KasbonRequest>> getList() async {
    final res = await _api.get(ApiEndpoints.kasbonList);
    final list = (res['data'] as List?) ?? [];
    return list.map((e) => KasbonRequest.fromJson(e)).toList();
  }

  /// POST /kasbon
  /// Body: { "amount": double, "reason": string }
  Future<KasbonRequest> create({required double amount, required String reason}) async {
    final res = await _api.post(
      ApiEndpoints.kasbonCreate,
      data: {'amount': amount, 'reason': reason},
    );
    return KasbonRequest.fromJson(res['data'] ?? res);
  }

  /// POST /kasbon/{id}/approve — khusus role approver
  Future<void> approve(String id) async {
    await _api.post('${ApiEndpoints.kasbonApprove}/$id/approve');
  }

  /// POST /kasbon/{id}/reject
  Future<void> reject(String id, {String? note}) async {
    await _api.post(
      '${ApiEndpoints.kasbonReject}/$id/reject',
      data: {'note': note},
    );
  }
}
