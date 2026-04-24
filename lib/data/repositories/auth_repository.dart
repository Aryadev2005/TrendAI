import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRepository {
  static const _userKey = 'cached_user';
  static const _tokenKey = 'auth_token';

  // ─── Login ────────────────────────────────────────────────────────────────
  Future<UserModel> login(String email, String password) async {
    // TODO: Replace with Firebase Auth when ready
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isEmpty || password.length < 6) {
      throw Exception('Invalid credentials');
    }

    final user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameFromEmail(email),
      email: email,
      createdAt: DateTime.now(),
    );

    await _cacheUser(user);
    await _saveToken('mock_token_${user.id}');
    return user;
  }

  // ─── Google Sign-In stub ──────────────────────────────────────────────────
  Future<UserModel> loginWithGoogle() async {
    // TODO: Implement Google Sign-In with firebase_auth + google_sign_in
    await Future.delayed(const Duration(milliseconds: 500));
    throw UnimplementedError('Google Sign-In coming soon');
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  // ─── Get cached user ──────────────────────────────────────────────────────
  Future<UserModel?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_userKey);
      if (json == null) return null;
      return UserModel.fromMap(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  // ─── Update profile ───────────────────────────────────────────────────────
  Future<UserModel> updateProfile(
    UserModel user, {
    String? followerRange,
    String? primaryPlatform,
    List<String>? niches,
  }) async {
    final updated = user.copyWith(
      followerRange: followerRange,
      primaryPlatform: primaryPlatform,
      niches: niches,
    );
    await _cacheUser(updated);
    return updated;
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  Future<void> _cacheUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    return local
        .split(RegExp(r'[._]'))
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ')
        .trim();
  }
}
