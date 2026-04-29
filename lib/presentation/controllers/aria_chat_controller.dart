// lib/presentation/controllers/aria_chat_controller.dart
// Riverpod state management for ARIA Brain chat.
// Handles: screen-aware context, greeting, message sending, history.
//
// Usage in any screen:
//   // Open Brain from Studio with script context:
//   context.push(AppRoutes.brain, extra: AriaSessionContext(
//     idea: 'Diwali skincare reel',
//     script: studioController.currentScript,
//     platform: 'Instagram',
//     format: 'Reel',
//   ));

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/aria_chat_repository.dart';

// ── State ────────────────────────────────────────────────────────────────────
class AriaChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isGreeting;
  final String? error;
  final String? greeting;
  final List<String> lastToolsUsed;

  const AriaChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isGreeting = false,
    this.error,
    this.greeting,
    this.lastToolsUsed = const [],
  });

  AriaChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isGreeting,
    String? error,
    String? greeting,
    List<String>? lastToolsUsed,
    bool clearError = false,
  }) {
    return AriaChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isGreeting: isGreeting ?? this.isGreeting,
      error: clearError ? null : error ?? this.error,
      greeting: greeting ?? this.greeting,
      lastToolsUsed: lastToolsUsed ?? this.lastToolsUsed,
    );
  }
}

// ── Controller ───────────────────────────────────────────────────────────────
class AriaChatController extends StateNotifier<AriaChatState> {
  final AriaChatRepository _repo;
  AriaSessionContext? _sessionContext;
  String _entryScreen = 'direct';

  AriaChatController(this._repo) : super(const AriaChatState());

  // ── Initialize with screen context ───────────────────────────────────────
  // Call this when BrainScreen opens, passing where the user came from
  Future<void> initialize({
    required String entryScreen,
    AriaSessionContext? context,
  }) async {
    _entryScreen = entryScreen;
    _sessionContext = context;

    // Load greeting
    state = state.copyWith(isGreeting: true);
    try {
      final greeting = await _repo.getGreeting(
        entryScreen: entryScreen,
        context: context,
      );
      state = state.copyWith(isGreeting: false, greeting: greeting);
    } catch (_) {
      state = state.copyWith(
        isGreeting: false,
        greeting: "Hey! What are we working on today?",
      );
    }
  }

  // ── Send a message ────────────────────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      messages: [
        ...state.messages,
        ChatMessage(role: 'user', content: text, timestamp: DateTime.now()),
      ],
    );

    try {
      final response = await _repo.sendMessage(
        message: text,
        entryScreen: _entryScreen,
        context: _sessionContext,
      );

      state = state.copyWith(
        isLoading: false,
        lastToolsUsed: response.toolsUsed,
        messages: [...state.messages, response],
      );
    } catch (e) {
      // Remove the optimistically added user message on failure
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
        messages: state.messages.sublist(0, state.messages.length - 1),
      );
    }
  }

  // ── Update context mid-session (e.g. user navigates back to Studio) ───────
  void updateContext(AriaSessionContext context) {
    _sessionContext = context;
  }

  void clearError() => state = state.copyWith(clearError: true);

  void clearHistory() {
    _repo.clearHistory();
    state = const AriaChatState();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────
final ariaChatRepositoryProvider = Provider((_) => AriaChatRepository());

final ariaChatProvider =
    StateNotifierProvider<AriaChatController, AriaChatState>(
  (ref) => AriaChatController(ref.read(ariaChatRepositoryProvider)),
);

// ── How to pass context from each screen ─────────────────────────────────────
//
// FROM DISCOVER SCREEN (user picked a trend):
//   context.push(AppRoutes.discover, extra: AriaSessionContext(
//     idea: selectedTrend.title,
//     platform: selectedTrend.platform,
//     trendTitle: selectedTrend.title,
//   ));
//   // In BrainScreen.initState:
//   ref.read(ariaChatProvider.notifier).initialize(
//     entryScreen: 'discover',
//     context: extra as AriaSessionContext,
//   );
//
// FROM STUDIO SCREEN (user has a script):
//   context.push(AppRoutes.studio, extra: AriaSessionContext(
//     idea: studioState.trendTitle,
//     script: studioState.script,
//     platform: studioState.platform,
//     format: studioState.selectedFormat,
//   ));
//   // In BrainScreen.initState:
//   ref.read(ariaChatProvider.notifier).initialize(
//     entryScreen: 'studio',
//     context: extra as AriaSessionContext,
//   );
//
// FROM LAUNCH SCREEN:
//   ref.read(ariaChatProvider.notifier).initialize(
//     entryScreen: 'launch',
//   );
//
// FROM BOTTOM NAV (direct open):
//   ref.read(ariaChatProvider.notifier).initialize(entryScreen: 'direct');
