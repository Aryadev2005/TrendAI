// lib/data/repositories/aria_chat_repository.dart
// Flutter data layer for ARIA Brain chat.
// Connects to POST /api/v1/brain/chat and GET /api/v1/brain/greet.
// Passes screen context, session ID, and conversation history automatically.

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

// ── Message model ─────────────────────────────────────────────────────────────
class ChatMessage {
  final String role;      // 'user' | 'assistant'
  final String content;
  final List<String> toolsUsed; // which tools ARIA called
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    this.toolsUsed = const [],
    required this.timestamp,
  });

  Map<String, dynamic> toHistoryMap() => {'role': role, 'content': content};
}

// ── Session context (passed from Discover/Studio/Launch screens) ──────────────
class AriaSessionContext {
  final String? idea;
  final String? script;
  final String? platform;
  final String? format;
  final String? trendTitle;

  const AriaSessionContext({
    this.idea,
    this.script,
    this.platform,
    this.format,
    this.trendTitle,
  });

  Map<String, dynamic> toMap() => {
    if (idea != null) 'idea': idea,
    if (script != null) 'script': script,
    if (platform != null) 'platform': platform,
    if (format != null) 'format': format,
    if (trendTitle != null) 'trendTitle': trendTitle,
  };

  bool get hasContext => idea != null || script != null || trendTitle != null;
}

// ── Repository ────────────────────────────────────────────────────────────────
class AriaChatRepository {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  // One session ID per app lifecycle — reset on app restart
  final String _sessionId = const Uuid().v4();

  // Rolling conversation history (last 20 messages)
  final List<ChatMessage> _history = [];

  String get sessionId => _sessionId;
  List<ChatMessage> get history => List.unmodifiable(_history);

  // ── Get proactive greeting when Brain opens ───────────────────────────────
  Future<String> getGreeting({
    required String entryScreen,
    AriaSessionContext? context,
  }) async {
    try {
      final token = await _getToken();
      final contextParam = context != null && context.hasContext
          ? '&context=${Uri.encodeComponent(jsonEncode(context.toMap()))}'
          : '';

      final uri = Uri.parse(
        '$_baseUrl/brain/greet?entryScreen=$entryScreen&sessionId=$_sessionId$contextParam',
      );

      final response = await _get(uri, token);
      if (response == null) return "Hey! What are we working on today?";

      return response['greeting'] as String? ?? "Hey! What are we working on today?";
    } catch (_) {
      return "Hey! What are we working on today?";
    }
  }

  // ── Send a message ────────────────────────────────────────────────────────
  Future<ChatMessage> sendMessage({
    required String message,
    required String entryScreen,
    AriaSessionContext? context,
  }) async {
    // Add user message to local history immediately
    final userMsg = ChatMessage(
      role: 'user',
      content: message,
      timestamp: DateTime.now(),
    );
    _history.add(userMsg);

    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/brain/chat');

    final body = {
      'message': message,
      'sessionId': _sessionId,
      'entryScreen': entryScreen,
      if (context != null && context.hasContext) 'context': context.toMap(),
      // Send last 10 messages as fallback (backend uses DB history if available)
      'conversationHistory': _history
          .take(_history.length - 1) // exclude the message we just added
          .toList()
          .reversed
          .take(10)
          .toList()
          .reversed
          .map((m) => m.toHistoryMap())
          .toList(),
    };

    final response = await _post(uri, token, body);

    if (response == null) {
      throw Exception('ARIA is unavailable right now. Please try again.');
    }

    final assistantMsg = ChatMessage(
      role: 'assistant',
      content: response['message'] as String,
      toolsUsed: (response['toolsUsed'] as List?)?.cast<String>() ?? [],
      timestamp: DateTime.now(),
    );

    _history.add(assistantMsg);

    // Keep rolling window
    if (_history.length > 40) {
      _history.removeRange(0, _history.length - 40);
    }

    return assistantMsg;
  }

  // ── Clear history (new session) ───────────────────────────────────────────
  void clearHistory() => _history.clear();

  // ── HTTP helpers ──────────────────────────────────────────────────────────
  Future<String?> _getToken() async {
    return FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<Map<String, dynamic>?> _get(Uri uri, String? token) async {
    try {
      final response = await http.get(
        uri,
        headers: _headers(token),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _post(Uri uri, String? token, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        uri,
        headers: _headers(token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        return responseBody['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}
