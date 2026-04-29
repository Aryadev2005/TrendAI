// lib/presentation/screens/agent/agent_chat_screen.dart
// ARIA Personal Agent Chat — free conversation, memory, action chips
// Also serves as the ARIA Brain with context-aware functionality

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../presentation/controllers/agent_chat_controller.dart';
import '../../../presentation/controllers/aria_chat_controller.dart';
import '../../../data/repositories/aria_chat_repository.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';
import '../../../routes/app_routes.dart';

class AgentChatScreen extends ConsumerStatefulWidget {
  final AriaSessionContext? ariaContext;
  
  const AgentChatScreen({super.key, this.ariaContext});
  @override
  ConsumerState<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends ConsumerState<AgentChatScreen> {
  final _input  = TextEditingController();
  final _scroll = ScrollController();
  final _focus  = FocusNode();

  // Quick-start prompts shown in empty state
  static const _starters = [
    'What should I post this week? 📅',
    'What are my competitors doing? 👀',
    'Give me a Reel idea with a hook 🎬',
    'What\'s trending in my niche right now 🔥',
    'How do I shoot a better hook shot? 📸',
    'What should I charge for a brand deal? 💰',
    'Analyse my content strategy honestly 🔍',
    'How do I edit jump cuts in CapCut? ✂️',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize ARIA Brain chat if context is provided
    if (widget.ariaContext != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(ariaChatProvider.notifier).initialize(
          entryScreen: 'studio',
          context: widget.ariaContext,
        );
      });
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send([String? override]) {
    final text = override ?? _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    ref.read(agentProvider.notifier).send(text);
    _scrollToBottom();
  }

  void _sendAriaBrain([String? override]) {
    final text = override ?? _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    ref.read(ariaChatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _navigate(String feature) {
    final routes = {
      'discover':  AppRoutes.discover,
      'studio':    AppRoutes.studio,
      'launch':    AppRoutes.launch,
      'calendar':  AppRoutes.dashboard,
      'ratecard':  AppRoutes.profile,
      'profile':   AppRoutes.profile,
    };
    context.go(routes[feature.toLowerCase()] ?? AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agentProvider);
    final ariaState = ref.watch(ariaChatProvider);

    ref.listen(agentProvider, (_, __) => _scrollToBottom());
    ref.listen(ariaChatProvider, (_, __) => _scrollToBottom());

    // Determine if we're in ARIA Brain mode (has context) or Agent mode
    final isAriaBrainMode = widget.ariaContext != null;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────
          _buildHeader(state),

          // ── Memory strip (collapsible) ────────────────────────────────
          if (state.memoryVisible && state.memory.isNotEmpty)
            _MemoryStrip(memory: state.memory),

          // ── Messages ─────────────────────────────────────────────────
          Expanded(
            child: isAriaBrainMode
                ? (ariaState.messages.isEmpty && ariaState.greeting != null
                    ? _AriaBrainEmptyState(greeting: ariaState.greeting!, onTap: _sendAriaBrain)
                    : (ariaState.messages.isEmpty
                        ? _EmptyState(starters: _starters, onTap: _send)
                        : ListView.builder(
                            controller:  _scroll,
                            padding:     const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            itemCount:   ariaState.messages.length,
                            itemBuilder: (_, i) => _AriaBrainBubble(
                              msg: ariaState.messages[i],
                              onCopy: (text) {
                                Clipboard.setData(ClipboardData(text: text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copied'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          )))
                : (state.messages.isEmpty
                    ? _EmptyState(starters: _starters, onTap: _send)
                    : ListView.builder(
                        controller:  _scroll,
                        padding:     const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        itemCount:   state.messages.length,
                        itemBuilder: (_, i) => _Bubble(
                          msg:        state.messages[i],
                          onNavigate: _navigate,
                          onCopy:     (text) {
                            Clipboard.setData(ClipboardData(text: text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      )),
          ),

          // ── Input bar ─────────────────────────────────────────────────
          _InputBar(
            controller: _input,
            focusNode:  _focus,
            isLoading:  isAriaBrainMode ? ariaState.isLoading : state.isLoading,
            onSend:     isAriaBrainMode ? _sendAriaBrain : _send,
          ),

          // Bottom nav spacing
          const SizedBox(height: 72),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }

  Widget _buildHeader(AgentState state) => SafeArea(
    bottom: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
      decoration: const BoxDecoration(
        color:  AppColors.bgPrimary,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        // ARIA avatar
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color:  AppColors.primary.withValues(alpha: 0.1),
            shape:  BoxShape.circle,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: const Center(child: Text('✨', style: TextStyle(fontSize: 17))),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ARIA', style: GoogleFonts.dmSerifDisplay(
            color: AppColors.textDark, fontSize: 17)),
          Text('Your personal creator agent',
            style: GoogleFonts.dmSans(color: AppColors.textMid, fontSize: 11)),
        ]),
        const Spacer(),

        // Memory toggle
        if (state.memory.isNotEmpty)
          GestureDetector(
            onTap: () => ref.read(agentProvider.notifier).toggleMemory(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin:  const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color:        state.memoryVisible
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border:       Border.all(color: state.memoryVisible
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.memory_rounded,
                  size:  13,
                  color: state.memoryVisible ? AppColors.primary : AppColors.textMid),
                const SizedBox(width: 4),
                Text('${state.memory.length}',
                  style: GoogleFonts.dmSans(
                    fontSize:   11,
                    fontWeight: FontWeight.w700,
                    color:      state.memoryVisible ? AppColors.primary : AppColors.textMid)),
              ]),
            ),
          ),

        // Clear
        GestureDetector(
          onTap: () => ref.read(agentProvider.notifier).clearChat(),
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.refresh_rounded,
              color: AppColors.textMid, size: 15),
          ),
        ),
      ]),
    ),
  );
}

// ─── ARIA Brain Empty State ───────────────────────────────────────────────────
class _AriaBrainEmptyState extends StatelessWidget {
  final String greeting;
  final void Function(String) onTap;
  const _AriaBrainEmptyState({required this.greeting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      child: Column(children: [
        const Text('✨', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text('ARIA Brain',
          style: GoogleFonts.dmSerifDisplay(
            color: AppColors.textDark, fontSize: 26)),
        const SizedBox(height: 8),
        Text(greeting,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 14, height: 1.5)),
      ]),
    );
  }
}

// ─── ARIA Brain Chat Bubble ───────────────────────────────────────────────────
class _AriaBrainBubble extends StatelessWidget {
  final ChatMessage msg;
  final void Function(String text) onCopy;
  const _AriaBrainBubble({required this.msg, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final isAria = msg.role == 'assistant';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            isAria ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                isAria ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isAria) ...[
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color:  AppColors.primary.withValues(alpha: 0.1),
                    shape:  BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Center(child: Text('✨', style: TextStyle(fontSize: 12))),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: GestureDetector(
                  onLongPress: () => onCopy(msg.content),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isAria ? AppColors.bgCard : AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft:     const Radius.circular(18),
                        topRight:    const Radius.circular(18),
                        bottomLeft:  Radius.circular(isAria ? 4 : 18),
                        bottomRight: Radius.circular(isAria ? 18 : 4),
                      ),
                      border: isAria
                          ? Border.all(color: AppColors.border, width: 0.5)
                          : null,
                    ),
                    child: Text(
                      msg.content,
                      style: GoogleFonts.dmSans(
                        color:  isAria ? AppColors.textDark : Colors.white,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
              ),
              if (!isAria) const SizedBox(width: 8),
            ],
          ),

          // Tools used indicator
          if (isAria && msg.toolsUsed.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: _ToolsUsedIndicator(tools: msg.toolsUsed),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tools Used Indicator ─────────────────────────────────────────────────────
class _ToolsUsedIndicator extends StatelessWidget {
  final List<String> tools;
  const _ToolsUsedIndicator({required this.tools});

  String _toolLabel(String tool) {
    final labels = {
      'live_trends': '📊 Checked live trends',
      'bgm_matcher': '🎵 Matched BGM',
      'script_optimizer': '📝 Optimized script',
      'hook_analyzer': '🎣 Analyzed hook',
      'engagement_predictor': '📈 Predicted engagement',
      'competitor_tracker': '👀 Tracked competitors',
      'viral_scorer': '🚀 Scored virality',
    };
    return labels[tool] ?? '✨ Used $tool';
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tools.take(3).map((tool) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Text(
          _toolLabel(tool),
          style: GoogleFonts.dmSans(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }
}

// ─── Memory Strip ─────────────────────────────────────────────────────────────
class _MemoryStrip extends StatelessWidget {
  final Map<String, dynamic> memory;
  const _MemoryStrip({required this.memory});

  @override
  Widget build(BuildContext context) {
    final entries = memory.entries.take(10).toList();
    return Container(
      height: 60,
      color: AppColors.bgCard,
      child: ListView.separated(
        padding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount:   entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final k = entries[i].key.replaceAll('_', ' ');
          final v = (entries[i].value as Map?)?['value'] ?? entries[i].value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text('$k: $v',
              style: GoogleFonts.dmSans(
                color: AppColors.textDark, fontSize: 11, fontWeight: FontWeight.w500)),
          );
        },
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final List<String> starters;
  final void Function(String) onTap;
  const _EmptyState({required this.starters, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      child: Column(children: [
        const Text('✨', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text('Ask me anything.',
          style: GoogleFonts.dmSerifDisplay(
            color: AppColors.textDark, fontSize: 26)),
        const SizedBox(height: 8),
        Text('Trending ideas, shooting tips, editing help,\nbrand strategy — I\'ve got you.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 14, height: 1.5)),
        const SizedBox(height: 32),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: starters.map((s) => GestureDetector(
            onTap: () => onTap(s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(s,
                style: GoogleFonts.dmSans(
                  color: AppColors.textDark, fontSize: 13)),
            ),
          )).toList(),
        ),
      ]),
    );
  }
}

// ─── Chat Bubble ──────────────────────────────────────────────────────────────
class _Bubble extends StatelessWidget {
  final ChatMsg msg;
  final void Function(String feature) onNavigate;
  final void Function(String text) onCopy;
  const _Bubble({required this.msg, required this.onNavigate, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    if (msg.isLoading) return const _TypingBubble();

    final isAria = msg.isAria;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            isAria ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                isAria ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isAria) ...[
                _ARIAAvatar(),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: GestureDetector(
                  onLongPress: () => onCopy(msg.content),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isAria ? AppColors.bgCard : AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft:     const Radius.circular(18),
                        topRight:    const Radius.circular(18),
                        bottomLeft:  Radius.circular(isAria ? 4 : 18),
                        bottomRight: Radius.circular(isAria ? 18 : 4),
                      ),
                      border: isAria
                          ? Border.all(color: AppColors.border, width: 0.5)
                          : null,
                    ),
                    child: Text(
                      msg.content,
                      style: GoogleFonts.dmSans(
                        color:  isAria ? AppColors.textDark : Colors.white,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
              ),
              if (!isAria) const SizedBox(width: 8),
            ],
          ),

          // Action chips
          if (msg.hasChips) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Wrap(
                spacing: 8, runSpacing: 6,
                children: msg.chips.map((chip) => GestureDetector(
                  onTap: () => onNavigate(chip.feature),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(chip.label,
                        style: GoogleFonts.dmSans(
                          color:      Colors.white,
                          fontSize:   12,
                          fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 13),
                    ]),
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ARIAAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(
      color:  AppColors.primary.withValues(alpha: 0.1),
      shape:  BoxShape.circle,
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: const Center(child: Text('✨', style: TextStyle(fontSize: 12))),
  );
}

// ─── Typing Indicator ─────────────────────────────────────────────────────────
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color:  AppColors.primary.withValues(alpha: 0.1),
              shape:  BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: const Center(child: Text('✨', style: TextStyle(fontSize: 12))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18),
                bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay  = i * 0.3;
                  final t      = (_ctrl.value - delay).clamp(0.0, 1.0);
                  final bounce = (t < 0.5 ? t * 2 : 2 - t * 2);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color:  AppColors.primary.withValues(alpha: 0.4 + bounce * 0.6),
                      shape: BoxShape.circle,
                    ),
                    transform: Matrix4.translationValues(0, -4 * bounce, 0),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input Bar ────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 10, 16, MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 16),
      decoration: const BoxDecoration(
        color:  AppColors.bgPrimary,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller:  controller,
              focusNode:   focusNode,
              maxLines:    4,
              minLines:    1,
              style: GoogleFonts.dmSans(
                color: AppColors.textDark, fontSize: 14),
              decoration: InputDecoration(
                hintText:  'Ask ARIA anything...',
                hintStyle: GoogleFonts.dmSans(
                  color: AppColors.textLight, fontSize: 14),
                border:        InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              ),
              textInputAction: TextInputAction.newline,
              onSubmitted: (_) => onSend(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: isLoading ? null : onSend,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isLoading
                  ? AppColors.border
                  : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.arrow_upward_rounded,
                    color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
