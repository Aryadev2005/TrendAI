import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/launch_model.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api/v1',
);

class LaunchRepository {
  LaunchRepository();

  Future<Map<String, String>> get _headers async {
    String? idToken;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        idToken = await user.getIdToken();
      }
    } catch (e) {
      debugPrint('[LAUNCH] ✗ Failed to get Firebase token: $e');
    }

    return {
      'Content-Type': 'application/json',
      if (idToken != null) 'Authorization': 'Bearer $idToken',
    };
  }

  /// GET /api/v1/launch/timing
  Future<TimingIntelligence> getTimingIntelligence() async {
    const url = '$_baseUrl/launch/timing';
    try {
      debugPrint('[LAUNCH] → GET $url');
      final headers = await _headers;
      final res = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      debugPrint('[LAUNCH] ← HTTP ${res.statusCode}');
      if (res.statusCode == 200) {
        debugPrint('[LAUNCH] ✓ Timing response body: ${res.body.substring(0, 200)}...');
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return TimingIntelligence.fromJson(body['data'] ?? body);
      }
      debugPrint('[LAUNCH] ✗ Timing error response: ${res.body}');
      throw Exception('Timing fetch failed: ${res.statusCode} - ${res.body}');
    } catch (e) {
      debugPrint('[LAUNCH] ✗ Timing exception: $e');
      rethrow;
    }
  }

  /// POST /api/v1/launch/package
  Future<PostingPackage> getPostingPackage({ String? idea, String? script }) async {
    const url = '$_baseUrl/launch/package';
    final body = jsonEncode({
      if (idea != null) 'idea': idea,
      if (script != null) 'script': script,
    });
    try {
      debugPrint('[LAUNCH] → POST $url');
      debugPrint('[LAUNCH] → Request body: $body');
      final headers = await _headers;
      final res = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 35));

      debugPrint('[LAUNCH] ← HTTP ${res.statusCode}');
      if (res.statusCode == 200) {
        debugPrint('[LAUNCH] ✓ Package response body: ${res.body.substring(0, 200)}...');
        final bodyMap = jsonDecode(res.body) as Map<String, dynamic>;
        return PostingPackage.fromJson(bodyMap['data'] ?? bodyMap);
      }
      debugPrint('[LAUNCH] ✗ Package error response: ${res.body}');
      throw Exception('Package generation failed: ${res.statusCode} - ${res.body}');
    } catch (e) {
      debugPrint('[LAUNCH] ✗ Package exception: $e');
      rethrow;
    }
  }

  /// GET /api/v1/launch/brand-alert
  Future<BrandAlert> getBrandAlert() async {
    const url = '$_baseUrl/launch/brand-alert';
    try {
      debugPrint('[LAUNCH] → GET $url');
      final headers = await _headers;
      final res = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(const Duration(seconds: 35));

      debugPrint('[LAUNCH] ← HTTP ${res.statusCode}');
      if (res.statusCode == 200) {
        debugPrint('[LAUNCH] ✓ BrandAlert response body: ${res.body.substring(0, 200)}...');
        final bodyMap = jsonDecode(res.body) as Map<String, dynamic>;
        return BrandAlert.fromJson(bodyMap['data'] ?? bodyMap);
      }
      debugPrint('[LAUNCH] ✗ BrandAlert error response: ${res.body}');
      throw Exception('Brand alert failed: ${res.statusCode} - ${res.body}');
    } catch (e) {
      debugPrint('[LAUNCH] ✗ BrandAlert exception: $e');
      rethrow;
    }
  }
}

final launchRepositoryProvider = Provider<LaunchRepository>((ref) {
  return LaunchRepository();
});
