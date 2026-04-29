// lib/data/repositories/onboarding_repository.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/aria_profile_model.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api/v1',
);

class OnboardingRepository {
  OnboardingRepository();

  Future<Map<String, String>> get _headers async {
    String? idToken;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        idToken = await user.getIdToken();
      }
    } catch (e) {
      debugPrint('[ONBOARDING] ✗ Failed to get Firebase token: $e');
    }

    return {
      'Content-Type': 'application/json',
      if (idToken != null) 'Authorization': 'Bearer $idToken',
    };
  }

  /// POST /api/v1/onboarding/connect
  /// Submits handle, triggers scrape + ARIA analysis
  Future<ARIAProfileAnalysis> connectHandle({
    required String handle,
    required String platform,
  }) async {
    final headers = await _headers;
    final res = await http.post(
      Uri.parse('$_baseUrl/onboarding/connect'),
      headers: headers,
      body: jsonEncode({ 'handle': handle, 'platform': platform }),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return ARIAProfileAnalysis.fromJson(body['data'] ?? body);
    }
    final err = jsonDecode(res.body);
    throw Exception(err['message'] ?? 'Failed to connect account');
  }

  /// POST /api/v1/onboarding/finalise
  /// Locks in the confirmed niche after user review
  Future<void> finaliseNiche({
    required List<String> confirmedNiches,
    required String confirmedArchetype,
    required String platform,
    required String followerRange,
  }) async {
    final headers = await _headers;
    final res = await http.post(
      Uri.parse('$_baseUrl/onboarding/finalise'),
      headers: headers,
      body: jsonEncode({
        'confirmedNiches':    confirmedNiches,
        'confirmedArchetype': confirmedArchetype,
        'platform':           platform,
        'followerRange':      followerRange,
      }),
    );
    if (res.statusCode != 200) {
      final err = jsonDecode(res.body);
      throw Exception(err['message'] ?? 'Failed to finalise niche');
    }
  }

  /// GET /api/v1/onboarding/status
  Future<Map<String, dynamic>> getStatus() async {
    final headers = await _headers;
    final res = await http.get(
      Uri.parse('$_baseUrl/onboarding/status'),
      headers: headers,
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['data'] ?? {};
    }
    return {};
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository();
});
