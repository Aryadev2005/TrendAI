// lib/presentation/screens/studio/studio_screen.dart
// ARIA Studio — Creator's workspace
// Script Editor (editable) | BGM Matcher | Editing Help | Video Analysis

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../presentation/controllers/studio_controller.dart';
import '../../../presentation/controllers/aria_session_controller.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';
import '../../../routes/app_routes.dart';

class StudioScreen extends ConsumerStatefulWidget {
  const StudioScreen({super.key});
  @override
  ConsumerState<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends ConsumerState<StudioScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  static const _tabLabels = ['Script', 'BGM', 'Editing', 'Analyse'];
  static const _tabIcons  = ['✍️', '🎵', '✂️', '🔍'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        ref.read(studioProvider.notifier).setTab(StudioTab.values[_tabs.index]);
      }
    });

    // Auto-generate script if we have an idea from session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(ariaSessionProvider);
      if (session.hasIdea && ref.read(studioProvider).sections.isEmpty) {
        ref.read(studioProvider.notifier).generateScript(
          idea:          session.idea!,
          platform:      session.platform,
          niche:         session.niche,
          format:        session.format,
          mood:          session.mood,
          collaboration: session.collaboration,
          angle:         session.angle,
        );
      }
    });
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(ariaSessionProvider);
    final state   = ref.watch(studioProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          _Header(session: session),
          _TabBar(controller: _tabs, labels: _tabLabels, icons: _tabIcons),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _ScriptTab(state: state, session: session),
                _BGMTab(state: state, session: session),
                _EditingTab(state: state),
                _AnalysisTab(state: state),
              ],
            ),
          ),
          const SizedBox(height: 72),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final AriaSession session;
  const _Header({required this.session});

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: BoxDecoration(
        color:  AppColors.bgPrimary,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('ARIA Studio', style: GoogleFonts.dmSerifDisplay(
              color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Text('🎬 In Progress', style: GoogleFonts.dmSans(
                color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
          if (session.hasIdea) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                Text('💡', style: GoogleFonts.dmSans(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  '${session.idea}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textMid, fontSize: 13),
                )),
              ]),
            ),
          ],
        ],
      ),
    ),
  );
}

// ─── Custom Tab Bar ───────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final TabController controller;
  final List<String> labels;
  final List<String> icons;
  const _TabBar({required this.controller, required this.labels, required this.icons});

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    color: AppColors.bgPrimary,
    child: TabBar(
      controller: controller,
      labelColor:         AppColors.primary,
      unselectedLabelColor: AppColors.textMid,
      indicatorColor:     AppColors.primary,
      indicatorWeight:    2,
      labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
      tabs: List.generate(labels.length, (i) => Tab(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(icons[i], style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(labels[i]),
        ]),
      )),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — SCRIPT EDITOR
// ─────────────────────────────────────────────────────────────────────────────
class _ScriptTab extends ConsumerWidget {
  final StudioState state;
  final AriaSession session;
  const _ScriptTab({required this.state, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.scriptLoading) return _Loading('ARIA is building your script...');
    if (state.sections.isEmpty) return _EmptyScript(session: session);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hook highlight card
          _HookCard(hookLine: state.hookLine, hookTip: state.hookTip),
          const SizedBox(height: 16),

          // Viral potential
          _ViralBar(score: state.viralPotential),
          const SizedBox(height: 20),

          // Editable sections
          Text('YOUR SCRIPT', style: GoogleFonts.dmSans(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          ...state.sections.map((s) => _SectionCard(
            section: s,
            isAdvising: state.advisingSection == s.id,
            idea: session.idea ?? '',
            mood: session.mood ?? 'informative',
          )),

          const SizedBox(height: 16),

          // ARIA shooting tips
          if (state.shootingTips.isNotEmpty) ...[
            _ShootingTipsCard(tips: state.shootingTips, mistake: state.commonMistake),
            const SizedBox(height: 16),
          ],

          // Regenerate
          GestureDetector(
            onTap: () {
              if (session.hasIdea) {
                ref.read(studioProvider.notifier).generateScript(
                  idea:          session.idea!,
                  platform:      session.platform,
                  niche:         session.niche,
                  format:        session.format,
                  mood:          session.mood,
                  collaboration: session.collaboration,
                  angle:         session.angle,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('🔄 Regenerate Script', style: GoogleFonts.dmSans(
                  color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HookCard extends StatelessWidget {
  final String hookLine;
  final String hookTip;
  const _HookCard({required this.hookLine, required this.hookTip});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.textDark,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('HOOK', style: GoogleFonts.dmSans(
              color: Colors.black, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Clipboard.setData(ClipboardData(text: hookLine)),
            child: const Icon(Icons.copy_rounded, color: Colors.white38, size: 16),
          ),
        ]),
        const SizedBox(height: 12),
        Text('"$hookLine"',
          style: GoogleFonts.dmSerifDisplay(
            color: Colors.white, fontSize: 18, height: 1.3)),
        const SizedBox(height: 10),
        Text(hookTip,
          style: GoogleFonts.dmSans(
            color: Colors.white60, fontSize: 12, height: 1.5)),
      ],
    ),
  );
}

class _ViralBar extends StatelessWidget {
  final int score;
  const _ViralBar({required this.score});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      Text('Viral Potential', style: GoogleFonts.dmSans(
        color: AppColors.textMid, fontSize: 12)),
      const SizedBox(width: 12),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: score / 100,
          backgroundColor: AppColors.border,
          color: score > 70 ? AppColors.rising : AppColors.primary,
          minHeight: 6,
        ),
      )),
      const SizedBox(width: 10),
      Text('$score%', style: GoogleFonts.dmSans(
        color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 13)),
    ]),
  );
}

class _SectionCard extends ConsumerStatefulWidget {
  final ScriptSection section;
  final bool isAdvising;
  final String idea;
  final String mood;
  const _SectionCard({
    required this.section,
    required this.isAdvising,
    required this.idea,
    required this.mood,
  });

  @override
  ConsumerState<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends ConsumerState<_SectionCard> {
  late final TextEditingController _ctrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.section.content);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = widget.section;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _editing ? AppColors.primary : AppColors.border,
          width: _editing ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('${s.label}',
                    style: GoogleFonts.dmSans(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.bgPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(s.duration,
                      style: GoogleFonts.dmSans(
                        color: AppColors.textMid, fontSize: 10)),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _editing = !_editing),
                    child: Text(_editing ? '✓ Done' : '✏️ Edit',
                      style: GoogleFonts.dmSans(
                        color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ],
            ),
          ),

          // Content (editable)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: _editing
                ? TextField(
                    controller: _ctrl,
                    maxLines: null,
                    style: GoogleFonts.dmSans(color: AppColors.textDark, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Edit your script...',
                      hintStyle: GoogleFonts.dmSans(color: AppColors.textMid),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                    onChanged: (v) {
                      ref.read(studioProvider.notifier).updateSection(s.id, v);
                    },
                  )
                : Text(s.content,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textMid, fontSize: 13, height: 1.5)),
          ),

          // ARIA tip
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💡', style: GoogleFonts.dmSans(fontSize: 12)),
                const SizedBox(width: 8),
                Expanded(child: Text(s.ariaTip,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textMid, fontSize: 12, height: 1.4,
                    fontStyle: FontStyle.italic))),
              ],
            ),
          ),

          // B-roll idea
          if (s.bRollIdea.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎬', style: GoogleFonts.dmSans(fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s.bRollIdea,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textMid, fontSize: 12, height: 1.4))),
                ],
              ),
            ),

          // ARIA advice (if requested)
          if (s.ariaAdvice != null && s.ariaAdvice!.isNotEmpty)
            _AriaAdvicePanel(
              section: s,
              onApply: () => ref.read(studioProvider.notifier).applySuggestion(s.id, s.ariaAdvice!),
              onDismiss: () => ref.read(studioProvider.notifier).dismissAdvice(s.id),
            ),

          // Bottom actions
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(studioProvider.notifier).adviseSection(s.id, widget.idea, widget.mood);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(widget.isAdvising ? '⏳ ARIA thinking...' : '✨ Ask ARIA',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AriaAdvicePanel extends StatelessWidget {
  final ScriptSection section;
  final VoidCallback onApply;
  final VoidCallback onDismiss;
  const _AriaAdvicePanel({
    required this.section, required this.onApply, required this.onDismiss});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.textDark,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('✨ ARIA suggests:', style: GoogleFonts.dmSans(
          color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text('"${section.ariaAdvice}"', style: GoogleFonts.dmSans(
          color: Colors.white, fontSize: 13, height: 1.5,
          fontStyle: FontStyle.italic)),
        const SizedBox(height: 10),
        Row(children: [
          GestureDetector(
            onTap: onApply,
            child: Text('✓ Apply',
              style: GoogleFonts.dmSans(
                color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDismiss,
            child: Text('✕ Dismiss',
              style: GoogleFonts.dmSans(
                color: AppColors.textMid, fontSize: 12)),
          ),
        ]),
      ],
    ),
  );
}

class _ShootingTipsCard extends StatelessWidget {
  final List<String> tips;
  final String mistake;
  const _ShootingTipsCard({required this.tips, required this.mistake});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📸 SHOOTING TIPS FROM ARIA', style: GoogleFonts.dmSans(
          color: AppColors.textMid, fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('•', style: GoogleFonts.dmSans(color: AppColors.primary, fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(child: Text(tip,
              style: GoogleFonts.dmSans(
                color: AppColors.textMid, fontSize: 12, height: 1.4))),
          ]),
        )),
        if (mistake.isNotEmpty) ...[
          const Divider(height: 16),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('⚠️', style: GoogleFonts.dmSans(fontSize: 12)),
            const SizedBox(width: 8),
            Expanded(child: Text(mistake,
              style: GoogleFonts.dmSans(
                color: AppColors.textMid, fontSize: 12, height: 1.4))),
          ]),
        ],
      ],
    ),
  );
}

class _EmptyScript extends ConsumerWidget {
  final AriaSession session;
  const _EmptyScript({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✍️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(session.hasIdea ? 'Ready to build your script' : 'No idea locked yet',
            style: GoogleFonts.dmSerifDisplay(color: AppColors.textDark, fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            session.hasIdea
                ? 'Tap the tabs above to explore Script, BGM, Editing, and Analysis tools'
                : 'Head to Discover to lock an idea and come back here',
            style: GoogleFonts.dmSans(color: AppColors.textMid, fontSize: 14, height: 1.5)),
          const SizedBox(height: 24),
          if (session.hasIdea)
            GestureDetector(
              onTap: () {
                ref.read(studioProvider.notifier).generateScript(
                  idea:          session.idea!,
                  platform:      session.platform,
                  niche:         session.niche,
                  format:        session.format,
                  mood:          session.mood,
                  collaboration: session.collaboration,
                  angle:         session.angle,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Build Script', style: GoogleFonts.dmSans(
                  color: Colors.black, fontWeight: FontWeight.w700)),
              ),
            )
          else
            GestureDetector(
              onTap: () => context.go(AppRoutes.discover),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Go to Discover', style: GoogleFonts.dmSans(
                  color: Colors.black, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — BGM MATCHER
// ─────────────────────────────────────────────────────────────────────────────
class _BGMTab extends ConsumerWidget {
  final StudioState state;
  final AriaSession session;
  const _BGMTab({required this.state, required this.session});

  static const _moods = [
    ('😂', 'funny'),       ('🥹', 'emotional'),
    ('📊', 'informative'), ('🔥', 'hype'),
    ('🎵', 'cinematic'),   ('😌', 'chill'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mood selector
          Text('SELECT MOOD', style: GoogleFonts.dmSans(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _moods.map((m) {
              final (emoji, mood) = m;
              final isSelected = state.selectedMood == mood;
              return GestureDetector(
                onTap: () => ref.read(studioProvider.notifier).setMood(mood),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(mood,
                      style: GoogleFonts.dmSans(
                        color: isSelected ? Colors.black : AppColors.textMid,
                        fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Match button
          GestureDetector(
            onTap: () {
              if (session.hasIdea) {
                ref.read(studioProvider.notifier).matchBGM(
                  session.idea!,
                  format: session.format,
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                state.bgmLoading ? '⏳ Matching...' : '🎵 Match BGM',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Audio strategy
          if (state.audioStrategy.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎯 AUDIO STRATEGY', style: GoogleFonts.dmSans(
                    color: AppColors.textMid, fontSize: 11,
                    fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text(state.audioStrategy,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textDark, fontSize: 13, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // BGM recommendations
          if (state.bgmRecs.isNotEmpty) ...[
            Text('RECOMMENDATIONS', style: GoogleFonts.dmSans(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            ...state.bgmRecs.map((bgm) => _BGMCard(
              bgm: bgm,
              onSelect: () => ref.read(studioProvider.notifier).selectBGM(bgm.rank),
            )),
          ],

          // Avoid this
          if (state.avoidThis.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚠️ AVOID THIS', style: GoogleFonts.dmSans(
                    color: AppColors.textMid, fontSize: 11,
                    fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text(state.avoidThis,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textDark, fontSize: 13, height: 1.5)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BGMCard extends StatelessWidget {
  final BGMRecommendation bgm;
  final VoidCallback onSelect;
  const _BGMCard({required this.bgm, required this.onSelect});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onSelect,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:  bgm.isSelected ? AppColors.textDark : AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:  bgm.isSelected ? AppColors.primary : AppColors.border,
          width:  bgm.isSelected ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${bgm.rank}. ${bgm.title}',
                  style: GoogleFonts.dmSans(
                    color: bgm.isSelected ? Colors.white : AppColors.textDark,
                    fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text('by ${bgm.artist}',
                  style: GoogleFonts.dmSans(
                    color: bgm.isSelected ? Colors.white60 : AppColors.textMid,
                    fontSize: 11)),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${bgm.viralPotential}%',
                  style: GoogleFonts.dmSans(
                    color: bgm.isSelected ? AppColors.primary : AppColors.textDark,
                    fontWeight: FontWeight.w700, fontSize: 12)),
                Text('viral',
                  style: GoogleFonts.dmSans(
                    color: bgm.isSelected ? Colors.white60 : AppColors.textMid,
                    fontSize: 10)),
              ],
            ),
            const SizedBox(width: 10),
            bgm.isSelected
                ? Icon(Icons.check_circle, color: AppColors.primary, size: 20)
                : Icon(Icons.radio_button_unchecked, color: AppColors.border, size: 20),
          ]),
          const SizedBox(height: 10),
          Text(bgm.why, style: GoogleFonts.dmSans(
            color: bgm.isSelected ? Colors.white60 : AppColors.textMid,
            fontSize: 12, height: 1.4)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgm.isSelected ? AppColors.primary : AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(bgm.timestampTip,
              style: GoogleFonts.dmSans(
                color: bgm.isSelected ? Colors.black : AppColors.textMid,
                fontSize: 10)),
          ),
          if (bgm.warning != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              Text('⚠️', style: GoogleFonts.dmSans(fontSize: 10)),
              const SizedBox(width: 4),
              Expanded(child: Text(bgm.warning!,
                style: GoogleFonts.dmSans(
                  color: bgm.isSelected ? Colors.white60 : AppColors.textMid,
                  fontSize: 10))),
            ]),
          ],
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — EDITING HELP
// ─────────────────────────────────────────────────────────────────────────────
class _EditingTab extends ConsumerStatefulWidget {
  final StudioState state;
  const _EditingTab({required this.state});

  @override
  ConsumerState<_EditingTab> createState() => _EditingTabState();
}

class _EditingTabState extends ConsumerState<_EditingTab> {
  final _ctrl = TextEditingController();

  static const _tools = ['CapCut', 'InShot', 'VN', 'Premiere', 'Final Cut', 'DaVinci'];

  static const _problems = [
    'How do I make jump cuts?',
    'How do I sync cuts to music?',
    'How do I add text overlays?',
    'How do I speed up / slow down clips?',
    'How do I colour grade my video?',
    'How do I add transitions?',
    'How do I remove background noise?',
    'How do I add captions automatically?',
    'How do I export for Instagram/YouTube?',
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tool selector
          Text('YOUR EDITING TOOL', style: GoogleFonts.dmSans(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _tools.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final tool = _tools[i];
                final isSelected = state.selectedTool == tool;
                return GestureDetector(
                  onTap: () => ref.read(studioProvider.notifier).setTool(tool),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border),
                    ),
                    child: Center(child: Text(tool,
                      style: GoogleFonts.dmSans(
                        color: isSelected ? Colors.black : AppColors.textMid,
                        fontWeight: FontWeight.w600, fontSize: 12))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Quick problem chips
          Text('QUICK PROBLEMS', style: GoogleFonts.dmSans(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _problems.map((p) => GestureDetector(
              onTap: () {
                _ctrl.text = p;
                ref.read(studioProvider.notifier).setProblem(p);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(p,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textMid, fontSize: 11)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // Custom problem input
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _ctrl,
              maxLines: 3,
              style: GoogleFonts.dmSans(color: AppColors.textDark, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Describe your editing problem...',
                hintStyle: GoogleFonts.dmSans(color: AppColors.textMid),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: (v) => ref.read(studioProvider.notifier).setProblem(v),
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => ref.read(studioProvider.notifier).getEditingHelp(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                state.editingLoading ? '⏳ Getting help...' : '✂️ Get Help',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),

          // Result
          if (state.editingResult != null) ...[
            const SizedBox(height: 20),
            _EditingResult(result: state.editingResult!),
          ],
        ],
      ),
    );
  }
}

class _EditingResult extends StatelessWidget {
  final Map<String, dynamic> result;
  const _EditingResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final steps = result['steps'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✨ SOLUTION', style: GoogleFonts.dmSans(
                color: AppColors.primary, fontSize: 11,
                fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text(result['solution'] ?? '',
                style: GoogleFonts.dmSans(
                  color: AppColors.textDark, fontSize: 13, height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(steps.length, (i) {
          final step = steps[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Step ${i + 1}',
                  style: GoogleFonts.dmSans(
                    color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(step,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textMid, fontSize: 12, height: 1.4)),
              ],
            ),
          );
        }),
        if ((result['proTip'] ?? '').isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💡', style: GoogleFonts.dmSans(fontSize: 12)),
                const SizedBox(width: 8),
                Expanded(child: Text(result['proTip'],
                  style: GoogleFonts.dmSans(
                    color: Colors.white60, fontSize: 12, height: 1.4))),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 4 — VIDEO ANALYSIS
// ─────────────────────────────────────────────────────────────────────────────
class _AnalysisTab extends ConsumerStatefulWidget {
  final StudioState state;
  const _AnalysisTab({required this.state});

  @override
  ConsumerState<_AnalysisTab> createState() => _AnalysisTabState();
}

class _AnalysisTabState extends ConsumerState<_AnalysisTab> {
  final _urlCtrl = TextEditingController();

  @override
  void dispose() { _urlCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state.videoAnalysis != null) {
      return _AnalysisResult(
        analysis: state.videoAnalysis!,
        onReset: () => ref.read(studioProvider.notifier).clearAnalysis(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PASTE VIDEO URL', style: GoogleFonts.dmSans(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _urlCtrl,
              style: GoogleFonts.dmSans(color: AppColors.textDark, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'https://youtube.com/watch?v=...',
                hintStyle: GoogleFonts.dmSans(color: AppColors.textMid),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (_urlCtrl.text.isNotEmpty) {
                ref.read(studioProvider.notifier).analyseVideoUrl(_urlCtrl.text);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                state.analysisLoading ? '⏳ Analysing...' : '🔍 Analyse Video',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📌 HOW IT WORKS', style: GoogleFonts.dmSans(
                  color: AppColors.textMid, fontSize: 11,
                  fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                const SizedBox(height: 10),
                ...['Hook strength', 'Pacing flow', 'Script impact', 'Viral potential'].map((item) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      Text('✓', style: GoogleFonts.dmSans(
                        color: AppColors.primary, fontSize: 12)),
                      const SizedBox(width: 8),
                      Text(item, style: GoogleFonts.dmSans(
                        color: AppColors.textMid, fontSize: 12)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisResult extends StatelessWidget {
  final VideoAnalysis analysis;
  final VoidCallback onReset;
  const _AnalysisResult({required this.analysis, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grade card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: analysis.overallScore > 70
                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                    : analysis.overallScore > 50
                    ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                    : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('OVERALL SCORE', style: GoogleFonts.dmSans(
                      color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700)),
                    Text(analysis.grade,
                      style: GoogleFonts.dmSerifDisplay(
                        color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('${analysis.overallScore}%', style: GoogleFonts.dmSans(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(analysis.verdict,
                  style: GoogleFonts.dmSans(
                    color: Colors.white60, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Estimated reach
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Now', style: GoogleFonts.dmSans(
                        color: AppColors.textMid, fontSize: 11)),
                      const SizedBox(height: 6),
                      Text(analysis.estimatedReach,
                        style: GoogleFonts.dmSans(
                          color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('After fixes', style: GoogleFonts.dmSans(
                        color: AppColors.textMid, fontSize: 11)),
                      const SizedBox(height: 6),
                      Text(analysis.estimatedReachAfterFixes,
                        style: GoogleFonts.dmSans(
                          color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Top priority fix
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.textDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🔥 TOP PRIORITY FIX', style: GoogleFonts.dmSans(
                  color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(analysis.topPriorityFix,
                  style: GoogleFonts.dmSans(
                    color: Colors.white, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Specific fixes
          if (analysis.specificFixes.isNotEmpty) ...[
            Text('SPECIFIC FIXES', style: GoogleFonts.dmSans(
              color: AppColors.textDark, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            ...analysis.specificFixes.map((fix) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: fix.priority == 'high'
                              ? const Color(0xFFEF4444)
                              : fix.priority == 'medium'
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(fix.priority.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Text(fix.timestamp,
                        style: GoogleFonts.dmSans(
                          color: AppColors.textMid, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Issue:', style: GoogleFonts.dmSans(
                    color: AppColors.textMid, fontSize: 10, fontWeight: FontWeight.w600)),
                  Text(fix.issue,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textDark, fontSize: 12, height: 1.3)),
                  const SizedBox(height: 8),
                  Text('Fix:', style: GoogleFonts.dmSans(
                    color: AppColors.textMid, fontSize: 10, fontWeight: FontWeight.w600)),
                  Text(fix.fix,
                    style: GoogleFonts.dmSans(
                      color: AppColors.textDark, fontSize: 12, height: 1.3)),
                ],
              ),
            )),
            const SizedBox(height: 20),
          ],

          // What worked
          if (analysis.whatWorked.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ WHAT WORKED', style: GoogleFonts.dmSans(
                    color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ...analysis.whatWorked.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•', style: GoogleFonts.dmSans(
                          color: AppColors.primary, fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item,
                          style: GoogleFonts.dmSans(
                            color: AppColors.textMid, fontSize: 12, height: 1.4))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Reset button
          GestureDetector(
            onTap: onReset,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text('← Back', textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading widget ───────────────────────────────────────────────────────────
class _Loading extends StatelessWidget {
  final String message;
  const _Loading(this.message);

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
      const SizedBox(height: 16),
      Text(message, style: GoogleFonts.dmSans(
        color: AppColors.textMid, fontSize: 14)),
    ]),
  );
}
