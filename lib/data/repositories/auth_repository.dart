import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class AuthRepository {
  static const _userKey = 'cached_user';

  // ─── Firebase Login → Backend Auth Flow ───────────────────────────────────
  // This is the CRITICAL flow: Firebase Auth → Get idToken → Backend auth
  Future<Map<String, dynamic>> firebaseLogin({required String? idToken, String? fcmToken, String? platform}) async {
    try {
      if (idToken == null) throw Exception('No Firebase token provided');
      final authService = AuthService();
      final authResponse = await authService.firebaseLogin(
        idToken: idToken,
        fcmToken: fcmToken,
        platform: platform ?? 'flutter',
      );
      final userData = authResponse['user'] as Map<String, dynamic>;
      final userModel = UserModel.fromMap(userData);
      await _cacheUser(userModel);
      return authResponse;
    } catch (e) {
      debugPrint('Firebase login error: $e');
      rethrow;
    }
  }

  // ─── Google Sign In ───────────────────────────────────────────────────────
  Future<UserModel> loginWithGoogle() async {
    // TODO: Implement real Google Sign In later
    // For now return a mock Google user
    await Future.delayed(const Duration(milliseconds: 800));

    final user = UserModel(
      id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Google User',
      email: 'googleuser@gmail.com',
      createdAt: DateTime.now(),
    );

    await _cacheUser(user);
    return user;
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      final authService = AuthService();
      await authService.logout();
    } catch (e) {
      // Log but continue with local logout
      debugPrint('Backend logout error: $e');
    }

    await FirebaseService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // ─── Get cached user ──────────────────────────────────────────────────────
  Future<UserModel?> getCachedUser() async {
    try {
      // Check Firebase session first
      final firebaseUser = FirebaseService.currentUser;
      if (firebaseUser == null) return null;

      // Try local cache
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_userKey);
      if (json != null) return UserModel.fromMap(jsonDecode(json));

      // Fallback to backend /auth/me
      try {
        final authService = AuthService();
        final userData = await authService.getMe();
        final user = UserModel.fromMap(userData['user'] as Map<String, dynamic>);
        await _cacheUser(user);
        return user;
      } catch (_) {
        // Backend call failed, try Firestore
        final fsData = await FirebaseService.getUser(firebaseUser.uid);
        if (fsData != null) {
          final user = UserModel.fromMap(fsData);
          await _cacheUser(user);
          return user;
        }
      }

      return null;
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

    // Save to Firestore + local cache
    await FirebaseService.saveUser(updated.toMap());
    await _cacheUser(updated);
    return updated;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Future<void> _cacheUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
  }
}