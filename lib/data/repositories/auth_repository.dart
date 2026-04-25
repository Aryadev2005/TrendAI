import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthRepository {
  static const _userKey = 'cached_user';

  // ─── Login with Firebase ──────────────────────────────────────────────────
  Future<UserModel> login(String email, String password) async {
    final result = await FirebaseService.signInWithEmail(email, password);
    if (result == null) throw Exception('Login failed');

    // Fetch full profile from Firestore
    final userData = await FirebaseService.getUser(result['uid']);

    final user = userData != null
        ? UserModel.fromMap(userData)
        : UserModel(
            id: result['uid'],
            name: result['name'] ?? _nameFromEmail(email),
            email: email,
            createdAt: DateTime.now(),
          );

    await _cacheUser(user);
    return user;
  }

  // ─── Register ─────────────────────────────────────────────────────────────
  Future<UserModel> register(
  String email,
  String password,
  String name,
) async {
  await Future.delayed(const Duration(milliseconds: 800));

  if (email.isEmpty || password.length < 6) {
    throw Exception('Invalid credentials');
  }

  final user = UserModel(
    id: 'user_${DateTime.now().millisecondsSinceEpoch}',
    name: name,
    email: email,
    createdAt: DateTime.now(),
  );

  await _cacheUser(user);
  await _saveToken('token_${user.id}');
  return user;
}
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

      // Fallback to Firestore
      final userData = await FirebaseService.getUser(firebaseUser.uid);
      if (userData != null) {
        final user = UserModel.fromMap(userData);
        await _cacheUser(user);
        return user;
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

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    return local
        .split(RegExp(r'[._]'))
        .map((w) => w.isEmpty
            ? ''
            : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ')
        .trim();
  }
}