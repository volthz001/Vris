// lib/core/services/api_client_simple.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_config.dart';

class ApiClient {
  // ============================================================
  // SINGLETON
  // ============================================================
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;
  factory ApiClient() => _instance;
  ApiClient._internal();

  // ============================================================
  // PROPERTIES
  // ============================================================
  late Dio _dio;
  bool _isInitialized = false;

  // Simpan session cookie manual
  String? _sessionCookie;

  // ============================================================
  // INIT
  // ============================================================
  void init() {
    if (_isInitialized) return;

    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status != null && status < 500,
    ));

    // Interceptor untuk menyimpan cookie manual
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Tambahkan cookie ke header jika ada
        if (_sessionCookie != null) {
          options.headers['Cookie'] = _sessionCookie!;
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Tangkap cookie dari response
        final cookieHeader = response.headers['set-cookie'];
        if (cookieHeader != null && cookieHeader.isNotEmpty) {
          _sessionCookie = cookieHeader.first;
          if (kDebugMode) {
            debugPrint('✅ Session cookie saved: $_sessionCookie');
          }
        }
        return handler.next(response);
      },
    ));

    // Logging
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (object) => debugPrint(object.toString()),
      ));
    }

    _isInitialized = true;
  }

  // ============================================================
  // PUBLIC METHODS
  // ============================================================

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      _ensureInitialized();
      final response = await _dio.get(path, queryParameters: queryParams);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      _ensureInitialized();
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParams,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      _ensureInitialized();
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParams,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      _ensureInitialized();
      final response = await _dio.delete(path, queryParameters: queryParams);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // ============================================================
  // AUTH
  // ============================================================

  Future<bool> login(String username, String password) async {
    try {
      _ensureInitialized();

      // Reset cookie sebelum login
      _sessionCookie = null;

      final response = await _dio.post(
        '/login',
        data: {
          'username': username,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          followRedirects: false,
        ),
      );

      // Cookie akan otomatis tersimpan di interceptor
      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _ensureInitialized();
      await _dio.get('/logout');
      _sessionCookie = null; // Hapus cookie
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  // ============================================================
  // PRIVATE
  // ============================================================

  void _ensureInitialized() {
    if (!_isInitialized) {
      init();
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    if (response.data == null) {
      return {'success': true, 'data': null};
    }

    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }

    if (response.data is String) {
      try {
        final decoded = jsonDecode(response.data);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
        return {'success': true, 'data': decoded};
      } catch (e) {
        return {'success': true, 'data': response.data};
      }
    }

    return {'success': true, 'data': response.data};
  }

  Map<String, dynamic> _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      String errorMessage = 'Terjadi kesalahan';

      if (data is Map) {
        errorMessage = data['message'] ?? data['error'] ?? 'Server error';
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map) {
            errorMessage = decoded['message'] ?? decoded['error'] ?? data;
          }
        } catch (_) {
          errorMessage = data;
        }
      }

      if (statusCode == 401) {
        throw Exception('Sesi habis. Silakan login ulang.');
      } else if (statusCode == 403) {
        throw Exception('Akses ditolak.');
      } else if (statusCode == 404) {
        throw Exception('Data tidak ditemukan.');
      } else {
        throw Exception(errorMessage);
      }
    }

    throw Exception('Koneksi error: ${e.message}');
  }
}
