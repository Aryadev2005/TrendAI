// lib/presentation/screens/profile/profile_screen.dart
// ARIA Creator Profile — platform-aware analytics command center
// Overview | Analytics | Account — adapts to Instagram vs YouTube

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/profile_model.dart';
import '../../../presentation/controllers/profile_controller.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          _Header(state: state),
          _TabBar(activeTab: state.activeTab),
          Expanded(
            child: state.isLoading
                ? const _FullLoader()
                : state.error != null
                    ? _ErrorView(
                        error: state.error!,
                        onRetry: () =>
                            ref.read(profileProvider.notifier).load(),
                      )
                    : _TabContent(state: state),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 4),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends ConsumerWidget {
  final ProfileState state;
  const _Header({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile   = state.profile;
    final analytics = state.analytics;
    final isYT      = (profile?.primaryPlatform ?? 'instagram') == 'youtube';

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Platform
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.dmSans(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (profile != null)
                      Text(
                        '${_archetypeEmoji(profile.archetype)} ${_archetypeLabel(profile.archetype)}',
                        style: GoogleFonts.dmSans(
                          color: AppColors.textMid,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isYT
                        ? Colors.red.withValues(alpha: 0.15)
                        : Colors.pink.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isYT
                          ? Colors.red.withValues(alpha: 0.3)
                          : Colors.pink.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    isYT ? '▶ YouTube' : '📷 Instagram',
                    style: GoogleFonts.dmSans(
                      color:
                          isYT ? Colors.red.shade400 : Colors.pink.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Handle + Followers
            if (analytics != null)
              Row(
                children: [
                  _Badge(
                    label: '@${analytics.handle}',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  _Badge(
                    label:
                        '${_fmt(analytics.followers)} ${isYT ? 'Subs' : 'Followers'}',
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 10),
                  if (analytics.fromCache)
                    _Badge(label: '⚡ Cached', color: Colors.orange),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _archetypeEmoji(String? a) {
    const map = {
      'TRENDSETTER': '✨', 'EDUCATOR': '📚', 'ENTERTAINER': '😂',
      'STORYTELLER': '🎬', 'CONNECTOR': '🤝', 'EXPERT': '🔬',
      'HUSTLER': '💼', 'ATHLETE': '💪', 'CHEF': '👨‍🍳', 'PERFORMER': '🎵',
    };
    return map[a] ?? '🎯';
  }

  String _archetypeLabel(String? a) {
    const map = {
      'TRENDSETTER': 'Trendsetter', 'EDUCATOR': 'Educator',
      'ENTERTAINER': 'Entertainer', 'STORYTELLER': 'Storyteller',
      'CONNECTOR': 'Connector', 'EXPERT': 'Expert',
      'HUSTLER': 'Hustler', 'ATHLETE': 'Athlete',
      'CHEF': 'Chef', 'PERFORMER': 'Performer',
    };
    return map[a] ?? 'Creator';
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(label, style: GoogleFonts.dmSans(
      color: color, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}

// ─── Tab Bar ──────────────────────────────────────────────────────────────────
class _TabBar extends ConsumerWidget {
  final int activeTab;
  const _TabBar({required this.activeTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const tabs = ['Overview', 'Analytics', 'Account'];
    return Container(
      height: 44,
      color: AppColors.bgPrimary,
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = i == activeTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(profileProvider.notifier).setTab(i),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      width: isActive ? 2 : 0,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: GoogleFonts.dmSans(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textMid,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Tab Content ──────────────────────────────────────────────────────────────
class _TabContent extends StatelessWidget {
  final ProfileState state;
  const _TabContent({required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state.activeTab) {
      case 0: return _OverviewTab(state: state);
      case 1: return _AnalyticsTab(state: state);
      case 2: return _AccountTab(state: state);
      default: return _OverviewTab(state: state);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — OVERVIEW
// ─────────────────────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final ProfileState state;
  const _OverviewTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final intel = state.analytics?.ariaIntelligence;
    final a     = state.analytics;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (intel != null) _HealthCard(intel: intel),
          const SizedBox(height: 20),
          if (a != null) _QuickStatsRow(analytics: a),
          const SizedBox(height: 20),
          if (intel != null) _ARIAVerdictCard(verdict: intel.ariaVerdict),
          const SizedBox(height: 20),
          if (intel != null) _OpportunityCard(opportunity: intel.topOpportunity),
          const SizedBox(height: 20),
          if (intel != null) _StrengthsGapsCard(intel: intel),
          const SizedBox(height: 20),
          if (intel != null) _MilestoneCard(intel: intel),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final ARIAIntelligence intel;
  const _HealthCard({required this.intel});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.textDark,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(children: [
      // Score circle
      SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: intel.healthScore / 100,
                color: intel.healthScore > 70
                    ? Colors.green
                    : intel.healthScore > 50
                        ? Colors.amber
                        : Colors.red,
                backgroundColor: Colors.grey.shade700,
                strokeWidth: 6,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${intel.healthScore}',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'Health',
                  style: GoogleFonts.dmSans(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(width: 20),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            intel.healthLabel,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            intel.growthStageLabel,
            style: GoogleFonts.dmSans(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              intel.growthStage,
              style: GoogleFonts.dmSans(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      )),
    ]),
  );
}

class _QuickStatsRow extends StatelessWidget {
  final CreatorAnalytics analytics;
  const _QuickStatsRow({required this.analytics});

  @override
  Widget build(BuildContext context) => Row(
    children: analytics.isYouTube ? [
      _StatBox(_formatNum(analytics.followers), 'Subscribers', Icons.people_rounded),
      const SizedBox(width: 10),
      _StatBox(_formatNum(analytics.avgViewsPerVideo ?? 0), 'Avg Views', Icons.visibility_rounded),
      const SizedBox(width: 10),
      _StatBox(analytics.uploadFrequency ?? '—', 'Frequency', Icons.upload_rounded),
    ] : [
      _StatBox(_formatNum(analytics.followers), 'Followers', Icons.people_rounded),
      const SizedBox(width: 10),
      _StatBox('${analytics.engagementRate}%', 'Engagement', Icons.favorite_rounded),
      const SizedBox(width: 10),
      _StatBox('${analytics.postsAnalyzed ?? 0}', 'Posts', Icons.grid_on_rounded),
    ],
  );

  Widget _StatBox(String value, String label, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.dmSans(
          color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.dmSans(
          color: AppColors.textMid, fontSize: 10)),
      ]),
    ),
  );

  String _formatNum(int n) {
    if (n >= 1000000) return '${(n/1000000).toStringAsFixed(1)}M';
    if (n >= 1000)    return '${(n/1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _ARIAVerdictCard extends StatelessWidget {
  final String verdict;
  const _ARIAVerdictCard({required this.verdict});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('✨ ', style: TextStyle(fontSize: 16)),
      Expanded(child: Text(verdict, style: GoogleFonts.dmSans(
        color: AppColors.textDark, fontSize: 13, height: 1.5))),
    ]),
  );
}

class _OpportunityCard extends StatelessWidget {
  final String opportunity;
  const _OpportunityCard({required this.opportunity});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('🎯 ', style: TextStyle(fontSize: 16)),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Opportunity', style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(opportunity, style: GoogleFonts.dmSans(
            color: AppColors.textDark, fontSize: 13, height: 1.4)),
        ],
      )),
    ]),
  );
}

class _StrengthsGapsCard extends StatelessWidget {
  final ARIAIntelligence intel;
  const _StrengthsGapsCard({required this.intel});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Strengths & Gaps', style: GoogleFonts.dmSans(
          color: AppColors.textMid, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...intel.strengths.map((s) => _row('💪', s, Colors.green)),
        if (intel.strengths.isNotEmpty && intel.gaps.isNotEmpty)
          const SizedBox(height: 8),
        ...intel.gaps.map((g) => _row('⚠️', g, Colors.orange.shade700)),
      ],
    ),
  );

  Widget _row(String emoji, String text, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: GoogleFonts.dmSans(
        color: AppColors.textDark, fontSize: 13, height: 1.4))),
    ]),
  );
}

class _MilestoneCard extends StatelessWidget {
  final ARIAIntelligence intel;
  const _MilestoneCard({required this.intel});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.15),
          AppColors.primary.withValues(alpha: 0.05),
        ],
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Next Milestone', style: GoogleFonts.dmSans(
          color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(intel.nextMilestone, style: GoogleFonts.dmSans(
          color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(intel.nextMilestoneAction, style: GoogleFonts.dmSans(
          color: AppColors.textMid, fontSize: 12, height: 1.4)),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — ANALYTICS (Platform-specific like VidIQ)
// ─────────────────────────────────────────────────────────────────────────────
class _AnalyticsTab extends StatelessWidget {
  final ProfileState state;
  const _AnalyticsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final a = state.analytics;
    if (a == null) return _FullLoader();
    return a.isYouTube ? _YouTubeAnalytics(a: a) : _InstagramAnalytics(a: a);
  }
}

class _YouTubeAnalytics extends StatelessWidget {
  final CreatorAnalytics a;
  const _YouTubeAnalytics({required this.a});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlatformHeader(
          emoji: '▶',
          name: a.channelName ?? a.handle,
          platform: 'YouTube Analytics',
          color: Colors.red,
        ),
        const SizedBox(height: 20),
        _SectionLabel('KEY METRICS'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _GridStat(_formatNum(a.followers), 'Subscribers', Icons.people_rounded),
            _GridStat(_formatNum(a.totalViews ?? 0), 'Total Views', Icons.visibility_rounded),
            _GridStat('${a.videoCount ?? 0}', 'Videos', Icons.play_circle_rounded),
            _GridStat(_formatNum(a.avgViewsPerVideo ?? 0), 'Avg Views/Video', Icons.trending_up_rounded),
          ],
        ),
        const SizedBox(height: 20),
        _SectionLabel('REVENUE'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RevenueBox(label: 'Est. CPM', value: a.estimatedCPM ?? '—'),
              _RevenueBox(label: 'Monthly Revenue', value: a.estimatedMonthlyRevenue ?? '—'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SectionLabel('TOP VIDEOS'),
        const SizedBox(height: 12),
        if (a.topVideos.isNotEmpty)
          ...a.topVideos.take(3).map((v) => _VideoCard(video: v))
        else
          Text('No video data available', style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 13)),
        const SizedBox(height: 20),
        _DataSourceNote(source: a.dataSource),
      ],
    ),
  );
}

class _InstagramAnalytics extends StatelessWidget {
  final CreatorAnalytics a;
  const _InstagramAnalytics({required this.a});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlatformHeader(
          emoji: '📷',
          name: a.handle,
          platform: 'Instagram Analytics',
          color: Colors.pink,
        ),
        const SizedBox(height: 20),
        _SectionLabel('KEY METRICS'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _GridStat(_formatNum(a.followers), 'Followers', Icons.people_rounded),
            _GridStat('${a.engagementRate}%', 'Engagement', Icons.favorite_rounded),
            _GridStat('${a.avgLikes ?? 0}', 'Avg Likes', Icons.favorite_rounded),
            _GridStat('${a.avgComments ?? 0}', 'Avg Comments', Icons.comment_rounded),
          ],
        ),
        const SizedBox(height: 20),
        _SectionLabel('CONTENT INSIGHTS'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                Text('Posts Analyzed', style: GoogleFonts.dmSans(
                  color: AppColors.textMid, fontSize: 11)),
                const SizedBox(height: 4),
                Text('${a.postsAnalyzed ?? 0}', style: GoogleFonts.dmSans(
                  color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
              Column(children: [
                Text('Posting Frequency', style: GoogleFonts.dmSans(
                  color: AppColors.textMid, fontSize: 11)),
                const SizedBox(height: 4),
                Text(a.postingFrequency ?? '—', style: GoogleFonts.dmSans(
                  color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SectionLabel('TOP HASHTAGS'),
        const SizedBox(height: 12),
        if (a.topHashtags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: a.topHashtags.take(8).map((h) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text('#$h', style: GoogleFonts.dmSans(
                  color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              );
            }).toList(),
          )
        else
          Text('No hashtag data', style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 13)),
        const SizedBox(height: 20),
        _DataSourceNote(source: a.dataSource),
      ],
    ),
  );
}

class _PlatformHeader extends StatelessWidget {
  final String emoji, name, platform;
  final Color color;
  const _PlatformHeader({
    required this.emoji, required this.name,
    required this.platform, required this.color,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
    ),
    const SizedBox(width: 12),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(name, style: GoogleFonts.dmSans(
        color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 15)),
      Text(platform, style: GoogleFonts.dmSans(
        color: AppColors.textMid, fontSize: 12)),
    ]),
  ]);
}

class _GridStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _GridStat(this.value, this.label, this.icon);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      Icon(icon, color: AppColors.primary, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.dmSans(
            color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      )),
    ]),
  );
}

class _RevenueBox extends StatelessWidget {
  final String label, value;
  const _RevenueBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: GoogleFonts.dmSans(color: Colors.white54, fontSize: 11)),
    const SizedBox(height: 4),
    Text(value, style: GoogleFonts.dmSans(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
  ]);
}

class _VideoCard extends StatelessWidget {
  final TopVideo video;
  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 60,
          height: 60,
          color: AppColors.border,
          child: Image.network(
            video.thumbnail,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Center(
              child: Icon(Icons.play_circle, color: AppColors.primary),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.visibility, size: 12, color: AppColors.textMid),
            const SizedBox(width: 4),
            Text(_formatNum(video.views), style: GoogleFonts.dmSans(
              color: AppColors.textMid, fontSize: 10)),
            const SizedBox(width: 12),
            Icon(Icons.favorite, size: 12, color: Colors.red),
            const SizedBox(width: 4),
            Text(_formatNum(video.likes), style: GoogleFonts.dmSans(
              color: AppColors.textMid, fontSize: 10)),
          ]),
        ],
      )),
    ]),
  );
}

class _DataSourceNote extends StatelessWidget {
  final String source;
  const _DataSourceNote({required this.source});

  @override
  Widget build(BuildContext context) {
    final isLive = source == 'youtube_data_api_v3';
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isLive ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isLive ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          isLive ? '✓ Live data from official API' : '⚡ Cached snapshot',
          style: GoogleFonts.dmSans(
            color: isLive ? Colors.green : Colors.orange,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.dmSans(
    color: AppColors.textMid, fontSize: 11,
    fontWeight: FontWeight.w700, letterSpacing: 1.5));
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — ACCOUNT
// ─────────────────────────────────────────────────────────────────────────────
class _AccountTab extends ConsumerWidget {
  final ProfileState state;
  const _AccountTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = state.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Info
          if (profile != null) ...[
            Text('Profile Info', style: GoogleFonts.dmSans(
              color: AppColors.textMid, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _InfoRow('Name', profile.name),
                  const Divider(height: 16),
                  _InfoRow('Email', profile.email),
                  const Divider(height: 16),
                  _InfoRow('Memory Count', '${profile.memoryCount} 💾'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Connected Platforms
          Text('Connected Platforms', style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          if (profile != null) ...[
            if (profile.youtubeHandle != null)
              _ConnectedPlatformCard(
                emoji: '▶',
                platform: 'YouTube',
                handle: profile.youtubeHandle,
                isActive: profile.primaryPlatform == 'youtube',
                color: Colors.red,
              ),
            const SizedBox(height: 10),
            if (profile.instagramHandle != null)
              _ConnectedPlatformCard(
                emoji: '📷',
                platform: 'Instagram',
                handle: profile.instagramHandle,
                isActive: profile.primaryPlatform == 'instagram',
                color: Colors.pink,
              ),
            const SizedBox(height: 24),
          ],
          // Subscription
          Text('Subscription', style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          if (profile != null)
            _SubscriptionCard(plan: profile.subscriptionPlan ?? 'free')
          else
            _SubscriptionCard(plan: 'free'),
          const SizedBox(height: 24),
          // Menu
          _MenuTile(
            icon: Icons.settings_rounded,
            label: 'Settings',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.logout_rounded,
            label: 'Logout',
            onTap: () {},
            isDestructive: true,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: GoogleFonts.dmSans(color: AppColors.textMid, fontSize: 12)),
      Text(value, style: GoogleFonts.dmSans(
        color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 12)),
    ],
  );
}

class _ConnectedPlatformCard extends StatelessWidget {
  final String emoji, platform;
  final String? handle;
  final bool isActive;
  final Color color;
  const _ConnectedPlatformCard({
    required this.emoji, required this.platform,
    this.handle, required this.isActive, required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isActive ? color.withValues(alpha: 0.1) : AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isActive ? color.withValues(alpha: 0.3) : AppColors.border,
        width: isActive ? 2 : 1,
      ),
    ),
    child: Row(children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(platform, style: GoogleFonts.dmSans(
            color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 2),
          Text(handle ?? 'Not connected', style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 11)),
        ],
      )),
      if (isActive)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('Active', style: GoogleFonts.dmSans(
            color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ),
    ]),
  );
}

class _SubscriptionCard extends StatelessWidget {
  final String plan;
  const _SubscriptionCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isPro = plan != 'free';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPro
              ? [Colors.amber.withValues(alpha: 0.15), Colors.orange.withValues(alpha: 0.05)]
              : [AppColors.bgCard, AppColors.bgCard],
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPro ? Colors.amber.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPro ? '⭐ ${plan.toUpperCase()}' : 'Free Plan',
                style: GoogleFonts.dmSans(
                  color: isPro ? Colors.amber.shade600 : AppColors.textMid,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isPro ? 'Premium features unlocked' : 'Upgrade to unlock more',
                style: GoogleFonts.dmSans(
                  color: AppColors.textMid,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (isPro)
            Icon(Icons.check_circle, color: Colors.amber.shade600, size: 24),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _MenuTile({
    required this.icon, required this.label,
    required this.onTap, this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDestructive ? Colors.red.withValues(alpha: 0.05) : AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDestructive ? Colors.red.withValues(alpha: 0.2) : AppColors.border,
        ),
      ),
      child: Row(children: [
        Icon(icon, color: isDestructive ? Colors.red : AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.dmSans(
          color: isDestructive ? Colors.red : AppColors.textDark,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        )),
      ]),
    ),
  );
}

// ─── Shared helpers ───────────────────────────────────────────────────────────
class _FullLoader extends StatelessWidget {
  const _FullLoader();
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2));
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text('Failed to load profile', style: GoogleFonts.dmSans(
            color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(error, style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 12, height: 1.4), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Retry', style: GoogleFonts.dmSans(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ],
      ),
    ),
  );
}

String _fmt(int n) {
  if (n >= 1000000) return '${(n/1000000).toStringAsFixed(1)}M';
  if (n >= 1000)    return '${(n/1000).toStringAsFixed(1)}K';
  return n.toString();
}

String _formatNum(int n) {
  if (n >= 1000000) return '${(n/1000000).toStringAsFixed(1)}M';
  if (n >= 1000)    return '${(n/1000).toStringAsFixed(1)}K';
  return n.toString();
}