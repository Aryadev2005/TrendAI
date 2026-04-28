// lib/data/repositories/discover_repository.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/radar_model.dart';

// ── Replace with your actual base URL / use an existing ApiClient if you have one ──
const _baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000/api/v1');
class DiscoverRepository {
  final String? authToken;
  DiscoverRepository({this.authToken});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  /// GET /api/v1/discover/intelligence
  Future<RadarIntelligence> getIntelligence() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/discover/intelligence'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return RadarIntelligence.fromJson(body['data'] ?? body);
    }
    throw Exception('Intelligence fetch failed: ${res.statusCode}');
  }

  /// GET /api/v1/discover/competitors
  Future<Map<String, dynamic>> getCompetitors() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/discover/competitors'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['data'] ?? body;
    }
    throw Exception('Competitors fetch failed: ${res.statusCode}');
  }

  /// GET /api/v1/discover/inspiration
  Future<List<Map<String, dynamic>>> getInspiration() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/discover/inspiration'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = body['data'] ?? body;
      final ideas = data['ideas'] as List? ?? [];
      return ideas.cast<Map<String, dynamic>>();
    }
    throw Exception('Inspiration fetch failed: ${res.statusCode}');
  }
}

// ─── Riverpod provider ────────────────────────────────────────────────────
// Wire up authToken from your existing authProvider if token property is added
final discoverRepositoryProvider = Provider<DiscoverRepository>((ref) {
  // TODO: plug in real token when available in AuthState → ref.watch(authProvider).token
  return DiscoverRepository(authToken: null);
});
