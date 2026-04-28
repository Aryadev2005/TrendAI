// lib/presentation/controllers/agent_chat_controller.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_controller.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api/v1',
);

// ─── Models ──────────────────────────────────────────────────────────────────
class ARIAChip {
  final String feature;
  final String label;
  const ARIAChip({required this.feature, required this.label});

  factory ARIAChip.fromJson(Map<String, dynamic> j) =>
      ARIAChip(feature: j['feature'] ?? '', label: j['label'] ?? '');
}

enum MsgRole { user, aria }

class ChatMsg {
  final String id;
  final MsgRole role;
  final String content;
  final List<ARIAChip> chips;
  final bool isLoading;
  final DateTime time;

  const ChatMsg({
    required this.id,
    required this.role,
    required this.content,
    this.chips     = const [],
    this.isLoading = false,
    required this.time,
  });

  bool get isAria  => role == MsgRole.aria;
  bool get isUser  => role == MsgRole.user;
  bool get hasChips => chips.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'role':      isUser ? 'user' : 'aria',
    'content':   content,
    'timestamp': time.toIso8601String(),
  };

  static ChatMsg user(String text) => ChatMsg(
    id: '${DateTime.now().microsecondsSinceEpoch}',
    role: MsgRole.user, content: text, time: DateTime.now());

  static ChatMsg aria(String text, {List<ARIAChip> chips = const []}) => ChatMsg(
    id: '${DateTime.now().microsecondsSinceEpoch}',
    role: MsgRole.aria, content: text, chips: chips, time: DateTime.now());

  static ChatMsg loading() => ChatMsg(
    id: 'loading', role: MsgRole.aria,
    content: '', isLoading: true, time: DateTime.now());
}

// ─── State ────────────────────────────────────────────────────────────────────
class AgentState {
  final List<ChatMsg> messages;
  final bool isLoading;
  final String? sessionId;
  final Map<String, dynamic> memory;
  final bool memoryVisible;

  const AgentState({
    this.messages      = const [],
    this.isLoading     = false,
    this.sessionId,
    this.memory        = const {},
    this.memoryVisible = false,
  });

  AgentState copyWith({
    List<ChatMsg>?         messages,
    bool?                  isLoading,
    String?                sessionId,
    Map<String, dynamic>?  memory,
    bool?                  memoryVisible,
  }) => AgentState(
    messages:      messages      ?? this.messages,
    isLoading:     isLoading     ?? this.isLoading,
    sessionId:     sessionId     ?? this.sessionId,
    memory:        memory        ?? this.memory,
    memoryVisible: memoryVisible ?? this.memoryVisible,
  );

  // History for backend (exclude loading msg)
  List<Map<String, dynamic>> get history =>
    messages.where((m) => !m.isLoading).map((m) => m.toJson()).toList();
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class AgentNotifier extends StateNotifier<AgentState> {
  final String? authToken;

  AgentNotifier({this.authToken}) : super(const AgentState()) {
    _welcome();
  }

  void _welcome() {
    state = state.copyWith(messages: [
      ChatMsg.aria(
        'Hey! I\'m ARIA ✨\n\nAsk me anything — what to post, how to shoot it, what\'s trending, what your competitors are doing, whether your idea is good or not.\n\nI\'ll give you a straight answer.',
      ),
    ]);
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;

    final userMsg  = ChatMsg.user(text.trim());
    final loadingMsg = ChatMsg.loading();

    state = state.copyWith(
      messages:  [...state.messages, userMsg, loadingMsg],
      isLoading: true,
    );

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/agent/message'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'message':   text.trim(),
          'sessionId': state.sessionId,
          'history':   state.history,
        }),
      ).timeout(const Duration(seconds: 35));

      if (res.statusCode == 200) {
        final data     = jsonDecode(res.body)['data'] as Map<String, dynamic>;
        final response = data['response']  as String? ?? '';
        final newSid   = data['sessionId'] as String?;
        final chipsRaw = data['chips']     as List?   ?? [];
        final chips    = chipsRaw
            .map((c) => ARIAChip.fromJson(c as Map<String, dynamic>))
            .toList();

        final msgs = state.messages
            .where((m) => !m.isLoading)
            .toList()
          ..add(ChatMsg.aria(response, chips: chips));

        state = state.copyWith(
          messages:  msgs,
          isLoading: false,
          sessionId: newSid ?? state.sessionId,
        );

        // Refresh memory silently
        _fetchMemory();
      } else {
        _handleError('ARIA is thinking too hard — try again in a sec!');
      }
    } catch (e) {
      _handleError('Connection issue yaar — is the backend running?');
    }
  }

  void _handleError(String msg) {
    final msgs = state.messages
        .where((m) => !m.isLoading)
        .toList()
      ..add(ChatMsg.aria(msg));
    state = state.copyWith(messages: msgs, isLoading: false);
  }

  Future<void> _fetchMemory() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/agent/memory'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );
      if (res.statusCode == 200) {
        final data   = jsonDecode(res.body)['data'] as Map<String, dynamic>;
        final memory = data['memory'] as Map<String, dynamic>? ?? {};
        state = state.copyWith(memory: memory);
      }
    } catch (_) {}
  }

  void toggleMemory() =>
      state = state.copyWith(memoryVisible: !state.memoryVisible);

  void clearChat() {
    state = const AgentState();
    _welcome();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final agentProvider = StateNotifierProvider<AgentNotifier, AgentState>((ref) {
  final authState = ref.watch(authProvider);
  String? token;
  
  // Get Firebase ID token if user is authenticated
  if (authState.isAuthenticated && authState.user != null) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      firebaseUser.getIdToken().then((idToken) {
        token = idToken;
      });
    }
  }
  
  return AgentNotifier(authToken: token);
});
