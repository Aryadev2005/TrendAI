// lib/data/repositories/onboarding_repository.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/aria_profile_model.dart';
import '../../presentation/controllers/auth_controller.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api/v1',
);

class OnboardingRepository {
  final String? authToken;
  OnboardingRepository({this.authToken});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  /// POST /api/v1/onboarding/connect
  /// Submits handle, triggers scrape + ARIA analysis
  Future<ARIAProfileAnalysis> connectHandle({
    required String handle,
    required String platform,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/onboarding/connect'),
      headers: _headers,
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
    final res = await http.post(
      Uri.parse('$_baseUrl/onboarding/finalise'),
      headers: _headers,
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
    final res = await http.get(
      Uri.parse('$_baseUrl/onboarding/status'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['data'] ?? {};
    }
    return {};
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final authToken = ref.watch(authProvider).user?.id;
  return OnboardingRepository(authToken: authToken);
});
