import 'package:trendai/data/services/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth Service - Firebase Token to Backend Auth Flow
// ─────────────────────────────────────────────────────────────────────────────

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final ApiClient _apiClient = ApiClient();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // ─────────────────────────────────────────────────────────────────────────
  // POST /auth/firebase
  // Sends Firebase idToken to backend, returns user + JWT
  // ─────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> firebaseLogin({
    required String idToken,
    String? fcmToken,
    String? platform,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/firebase',
        data: {
          'idToken': idToken,
          'fcmToken': fcmToken, // TODO: replace with real FCM token
          'platform': platform ?? 'flutter',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      }

      throw ApiException(
        error: response['error'] ?? 'LOGIN_FAILED',
        message: response['message'] ?? 'Failed to login',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // POST /auth/logout
  // Logs out the user on the backend
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Log but don't throw - logout should always succeed on client side
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET /auth/me
  // Gets current authenticated user info
  // ─────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _apiClient.get('/auth/me');

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      }

      throw ApiException(
        error: response['error'] ?? 'GET_USER_FAILED',
        message: response['message'] ?? 'Failed to fetch user data',
      );
    } catch (e) {
      rethrow;
    }
  }
}
