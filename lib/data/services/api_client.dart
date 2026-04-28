import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// API Exception
// ─────────────────────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String error;
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({
    required this.error,
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ApiException($statusCode): [$error] $message';
}

// ─────────────────────────────────────────────────────────────────────────────
// Singleton Dio HTTP Client
// ─────────────────────────────────────────────────────────────────────────────

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    const baseUrl = kDebugMode
        ? 'http://localhost:3000/api/v1'
        : 'https://api.trendai.in/api/v1';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (_) => true, // Allow all status codes for custom handling
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
  }

  Dio get dio => _dio;

  // Update base URL at runtime (for testing different environments)
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  // GET request
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request
  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Interceptor - Attaches Firebase token to every request
// ─────────────────────────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get fresh token (with force refresh if needed)
        final idToken = await user.getIdToken(true);
        options.headers['Authorization'] = 'Bearer $idToken';
      }
    } catch (e) {
      // Log error but continue - user may not be authenticated
      debugPrint('Auth interceptor error: $e');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // If 401 (token expired), try to refresh and retry
    if (err.response?.statusCode == 401) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Force refresh the token
          await user.getIdToken(true);

          // Retry the request with new token
          final newOptions = err.requestOptions;
          final idToken = await user.getIdToken();
          newOptions.headers['Authorization'] = 'Bearer $idToken';

          final response = await ApiClient()._dio.request(
            newOptions.path,
            options: Options(
              method: newOptions.method,
              headers: newOptions.headers,
            ),
            data: newOptions.data,
            queryParameters: newOptions.queryParameters,
          );

          return handler.resolve(response);
        }
      } catch (e) {
        debugPrint('Token refresh failed: $e');
      }
    }

    return handler.next(err);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Interceptor - Parses and throws typed ApiException
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Check if response has error structure
    if (response.statusCode! >= 400) {
      final data = response.data as Map<String, dynamic>?;

      if (data != null && data['success'] == false) {
        throw ApiException(
          statusCode: response.statusCode,
          error: data['error'] ?? 'UNKNOWN_ERROR',
          message: data['message'] ?? 'An error occurred',
          originalError: response.data,
        );
      }
    }

    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data as Map<String, dynamic>?;

    // Parse backend error response
    if (data != null && data['success'] == false) {
      throw ApiException(
        statusCode: statusCode,
        error: data['error'] ?? 'UNKNOWN_ERROR',
        message: data['message'] ?? 'An error occurred',
        originalError: err,
      );
    }

    // Handle network errors
    if (err.error is SocketException) {
      throw ApiException(
        error: 'NO_INTERNET',
        message: 'No internet connection',
        originalError: err,
      );
    }

    // Handle timeout
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      throw ApiException(
        error: 'TIMEOUT',
        message: 'Request timeout. Please try again.',
        originalError: err,
      );
    }

    // Wrap other DioExceptions
    throw ApiException(
      statusCode: statusCode,
      error: err.type.toString(),
      message: err.message ?? 'An error occurred',
      originalError: err,
    );
  }
}
