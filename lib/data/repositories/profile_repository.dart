// lib/data/repositories/profile_repository.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api/v1',
);

class ProfileRepository {
  ProfileRepository();

  Future<Map<String, String>> get _headers async {
    String? idToken;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) idToken = await user.getIdToken();
    } catch (e) {
      debugPrint('[PROFILE] ✗ Token error: $e');
    }
    return {
      'Content-Type': 'application/json',
      if (idToken != null) 'Authorization': 'Bearer $idToken',
    };
  }

  /// GET /api/v1/profile/me
  Future<CreatorProfile> getProfile() async {
    final headers = await _headers;
    debugPrint('[PROFILE] → GET /profile/me');
    final res = await http.get(
      Uri.parse('$_baseUrl/profile/me'),
      headers: headers,
    ).timeout(const Duration(seconds: 15));

    debugPrint('[PROFILE] ← ${res.statusCode}');
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return CreatorProfile.fromJson(body['data'] ?? body);
    }
    throw Exception('Profile fetch failed: ${res.statusCode}');
  }

  /// GET /api/v1/profile/analytics
  /// Platform-aware — backend routes to YouTube or Instagram automatically
  Future<CreatorAnalytics> getAnalytics() async {
    final headers = await _headers;
    debugPrint('[PROFILE] → GET /profile/analytics');
    final res = await http.get(
      Uri.parse('$_baseUrl/profile/analytics'),
      headers: headers,
    ).timeout(const Duration(seconds: 30));

    debugPrint('[PROFILE] ← ${res.statusCode}');
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return CreatorAnalytics.fromJson(body['data'] ?? body);
    }
    throw Exception('Analytics fetch failed: ${res.statusCode}');
  }

  /// POST /api/v1/profile/refresh
  Future<CreatorAnalytics> refreshAnalytics() async {
    final headers = await _headers;
    debugPrint('[PROFILE] → POST /profile/refresh');
    final res = await http.post(
      Uri.parse('$_baseUrl/profile/refresh'),
      headers: headers,
    ).timeout(const Duration(seconds: 45));

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return CreatorAnalytics.fromJson(body['data'] ?? body);
    }
    throw Exception('Refresh failed: ${res.statusCode}');
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (_) => ProfileRepository());
