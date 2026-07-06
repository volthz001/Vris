/// Exception terstruktur untuk error dari API, supaya UI bisa tampilkan
/// pesan yang sesuai tanpa parsing ulang di setiap screen.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ApiException(this.message, {this.statusCode, this.errorCode});

  @override
  String toString() => message;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => (statusCode ?? 0) >= 500;
  bool get isNetworkError => statusCode == null;
}
