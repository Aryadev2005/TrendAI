// ARIA Launch — Timing Intelligence | Posting Package | Brand Deals
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/launch_model.dart';
import '../../../presentation/controllers/launch_controller.dart';
import '../../../presentation/controllers/aria_session_controller.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';

class LaunchScreen extends ConsumerStatefulWidget {
  const LaunchScreen({super.key});
  @override
  ConsumerState<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends ConsumerState<LaunchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  static const _labels = ['Timing', 'Package', 'Brands'];
  static const _icons  = ['⏰', '📦', '💼'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) return;
      ref.read(launchProvider.notifier).setTab(LaunchTab.values[_tabs.index]);

      // Lazy-load each tab on first visit
      final state = ref.read(launchProvider);
      switch (_tabs.index) {
        case 1:
          if (state.package == null && !state.packageLoading) {
            ref.read(launchProvider.notifier).fetchPostingPackage();
          }
          break;
        case 2:
          if (state.brandAlert == null && !state.brandsLoading) {
            ref.read(launchProvider.notifier).fetchBrandAlert();
          }
          break;
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(ariaSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          _Header(session: session),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _TimingTab(),
                _PackageTab(),
                _BrandsTab(),
              ],
            ),
          ),
          const SizedBox(height: 72),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }

  Widget _buildTabBar() => Container(
    color: AppColors.bgPrimary,
    child: TabBar(
      controller: _tabs,
      labelColor:           AppColors.primary,
      unselectedLabelColor: AppColors.textMid,
      indicatorColor:       AppColors.primary,
      indicatorWeight:      2,
      labelStyle:   GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
      tabs: List.generate(3, (i) => Tab(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(_icons[i], style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(_labels[i]),
        ]),
      )),
    ),
  );
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
      decoration: const BoxDecoration(
        color:  AppColors.bgPrimary,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Launch', style: GoogleFonts.dmSerifDisplay(
            color: AppColors.textDark, fontSize: 22)),
          Text('Drop it at the right time', style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 12)),
        ]),
        const Spacer(),
        if (session.hasIdea)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text('🚀 Ready', style: GoogleFonts.dmSans(
              color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — TIMING INTELLIGENCE
// ─────────────────────────────────────────────────────────────────────────────
class _TimingTab extends ConsumerWidget {
  const _TimingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(launchProvider);

    if (state.timingLoading) return const _Loading('ARIA is reading your audience...');
    if (state.timing == null && state.error != null) return _Error(onRetry: () => ref.read(launchProvider.notifier).fetchTiming());
    if (state.timing == null) return const _Loading('Loading timing data...');

    final t = state.timing!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next best slot banner
          _NextSlotBanner(slot: t.nextBestSlot, hoursAway: t.nextBestSlotHoursAway),
          const SizedBox(height: 20),

          // ARIA reason card
          _ARIACard(text: t.ariaReason),
          const SizedBox(height: 20),

          // Best slots
          const _SectionLabel('BEST POSTING WINDOWS'),
          const SizedBox(height: 12),
          ...t.bestSlots.map((s) => _SlotCard(slot: s)),

          const SizedBox(height: 20),

          // Platform insight
          _InfoTile('📱 Platform insight', t.platformInsight),
          const SizedBox(height: 10),
          _InfoTile('📅 Weekly pattern', t.weeklyPattern),
          const SizedBox(height: 10),

          // Avoid windows
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⛔ Avoid these windows', style: GoogleFonts.dmSans(
                  color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...t.avoidWindows.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $w', style: GoogleFonts.dmSans(
                    color: AppColors.textMid, fontSize: 13)),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Refresh
          _RefreshButton(onTap: () => ref.read(launchProvider.notifier).fetchTiming()),
        ],
      ),
    );
  }
}

class _NextSlotBanner extends StatelessWidget {
  final String slot;
  final int hoursAway;
  const _NextSlotBanner({required this.slot, required this.hoursAway});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
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
            child: Text('NEXT BEST SLOT', style: GoogleFonts.dmSans(
              color: Colors.black, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          Text(
            hoursAway <= 0 ? 'Now' : 'In ${hoursAway}h',
            style: GoogleFonts.dmSans(color: AppColors.textMid, fontSize: 12),
          ),
        ]),
        const SizedBox(height: 12),
        Text(slot, style: GoogleFonts.dmSerifDisplay(
          color: Colors.white, fontSize: 26)),
        const SizedBox(height: 4),
        Text('Post within this window for maximum reach',
          style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 12)),
      ],
    ),
  );
}

class _SlotCard extends StatelessWidget {
  final TimingSlot slot;
  const _SlotCard({required this.slot});

  Color get _scoreColor => slot.score >= 90
      ? AppColors.rising
      : slot.score >= 80
          ? AppColors.primary
          : AppColors.textMid;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _scoreColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text('${slot.score}', style: GoogleFonts.dmSans(
              color: _scoreColor, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${slot.day}  ${slot.time}', style: GoogleFonts.dmSans(
                color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              Text(slot.reason, style: GoogleFonts.dmSans(
                color: AppColors.textMid, fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — POSTING PACKAGE
// ─────────────────────────────────────────────────────────────────────────────
class _PackageTab extends ConsumerWidget {
  const _PackageTab();

  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label copied'),
      duration: const Duration(seconds: 1),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state   = ref.watch(launchProvider);
    final session = ref.watch(ariaSessionProvider);

    if (state.packageLoading) return const _Loading('Building your posting package...');
    if (state.package == null && state.error != null) {
      return _Error(onRetry: () => ref.read(launchProvider.notifier).fetchPostingPackage());
    }

    if (state.package == null) {
      // Not yet loaded — show a generate button
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📦', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              Text('Ready to launch?', style: GoogleFonts.dmSerifDisplay(
                color: AppColors.textDark, fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                session.hasIdea
                    ? 'ARIA will generate your full posting package for\n"${session.idea}"'
                    : 'ARIA will generate your full posting package — caption, hashtags, first comment, and more.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: AppColors.textMid, fontSize: 13, height: 1.5)),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => ref.read(launchProvider.notifier).fetchPostingPackage(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('Generate Package', style: GoogleFonts.dmSans(
                    color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pkg = state.package!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Best day/time chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('⏰', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text('Best time: ${pkg.bestDayTime}', style: GoogleFonts.dmSans(
                color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 16),

          // ARIA posting tip
          _ARIACard(text: pkg.ariaPostingTip),
          const SizedBox(height: 20),

          // Caption
          _CopyBlock(
            label: 'CAPTION',
            content: pkg.caption,
            onCopy: () => _copy(context, pkg.caption, 'Caption'),
          ),
          const SizedBox(height: 12),

          // First comment
          _CopyBlock(
            label: 'FIRST COMMENT',
            content: pkg.firstComment,
            onCopy: () => _copy(context, pkg.firstComment, 'First comment'),
          ),
          const SizedBox(height: 12),

          // Hashtags
          _HashtagBlock(hashtags: pkg.hashtags, onCopy: (text) => _copy(context, text, 'Hashtags')),
          const SizedBox(height: 12),

          // Story copy
          if (pkg.storyCopy.isNotEmpty) ...[
            _CopyBlock(
              label: 'STORY COPY',
              content: pkg.storyCopy,
              onCopy: () => _copy(context, pkg.storyCopy, 'Story copy'),
            ),
            const SizedBox(height: 12),
          ],

          // Thumbnail text
          if (pkg.thumbnailText.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.textDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('THUMBNAIL TEXT', style: GoogleFonts.dmSans(
                        color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                      const SizedBox(height: 6),
                      Text(pkg.thumbnailText, style: GoogleFonts.dmSerifDisplay(
                        color: Colors.white, fontSize: 20)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _copy(context, pkg.thumbnailText, 'Thumbnail text'),
                  child: const Icon(Icons.copy_rounded, color: Colors.white38, size: 18),
                ),
              ]),
            ),
          const SizedBox(height: 12),

          // Estimated reach
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              const Text('📈', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Estimated reach', style: GoogleFonts.dmSans(
                  color: AppColors.textMid, fontSize: 11)),
                Text(pkg.estimatedReach, style: GoogleFonts.dmSans(
                  color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 14)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // Regenerate
          _RefreshButton(onTap: () => ref.read(launchProvider.notifier).fetchPostingPackage()),
        ],
      ),
    );
  }
}

class _CopyBlock extends StatelessWidget {
  final String label;
  final String content;
  final VoidCallback onCopy;
  const _CopyBlock({required this.label, required this.content, required this.onCopy});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label, style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 10,
            fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const Spacer(),
          GestureDetector(
            onTap: onCopy,
            child: const Icon(Icons.copy_rounded, color: AppColors.textMid, size: 16),
          ),
        ]),
        const SizedBox(height: 8),
        Text(content, style: GoogleFonts.dmSans(
          color: AppColors.textDark, fontSize: 13, height: 1.5)),
      ],
    ),
  );
}

class _HashtagBlock extends StatelessWidget {
  final HashtagSet hashtags;
  final void Function(String) onCopy;
  const _HashtagBlock({required this.hashtags, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final all = hashtags.all.join(' ');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('HASHTAGS', style: GoogleFonts.dmSans(
              color: AppColors.textMid, fontSize: 10,
              fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            const Spacer(),
            GestureDetector(
              onTap: () => onCopy(all),
              child: const Icon(Icons.copy_rounded, color: AppColors.textMid, size: 16),
            ),
          ]),
          const SizedBox(height: 10),
          _HashtagRow('Mega', hashtags.mega, AppColors.hot),
          _HashtagRow('Mid', hashtags.mid, AppColors.primary),
          _HashtagRow('Niche', hashtags.niche, AppColors.newBadge),
        ],
      ),
    );
  }
}

class _HashtagRow extends StatelessWidget {
  final String tier;
  final List<String> tags;
  final Color color;
  const _HashtagRow(this.tier, this.tags, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          child: Text(tier, style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 11)),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(tag, style: GoogleFonts.dmSans(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — BRAND DEALS
// ─────────────────────────────────────────────────────────────────────────────
class _BrandsTab extends ConsumerWidget {
  const _BrandsTab();

  void _copy(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label copied'),
      duration: const Duration(seconds: 1),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(launchProvider);

    if (state.brandsLoading) return const _Loading('ARIA is finding brand matches...');
    if (state.brandAlert == null && state.error != null) {
      return _Error(onRetry: () => ref.read(launchProvider.notifier).fetchBrandAlert());
    }

    if (state.brandAlert == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💼', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              Text('Brand deal opportunities', style: GoogleFonts.dmSerifDisplay(
                color: AppColors.textDark, fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                'ARIA scans for brands that match your niche, audience size, and engagement right now.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(color: AppColors.textMid, fontSize: 13, height: 1.5)),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => ref.read(launchProvider.notifier).fetchBrandAlert(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('Find Brand Matches', style: GoogleFonts.dmSans(
                    color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final alert = state.brandAlert!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ARIACard(text: alert.ariaAdvice),
          const SizedBox(height: 20),

          const _SectionLabel('BRAND MATCHES'),
          const SizedBox(height: 12),
          ...alert.brandOpportunities.map((b) => _BrandCard(brand: b)),
          const SizedBox(height: 20),

          const _SectionLabel('PITCH TEMPLATE'),
          const SizedBox(height: 12),

          // Email subject
          _CopyableRow(
            label: 'EMAIL SUBJECT',
            value: alert.pitchTemplate.subject,
            onCopy: () => _copy(context, alert.pitchTemplate.subject, 'Subject'),
          ),
          const SizedBox(height: 10),

          // Full email body
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
                Row(children: [
                  Text('EMAIL BODY', style: GoogleFonts.dmSans(
                    color: AppColors.textMid, fontSize: 10,
                    fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _copy(context, alert.pitchTemplate.body, 'Email body'),
                    child: const Icon(Icons.copy_rounded, color: AppColors.textMid, size: 16),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(alert.pitchTemplate.body, style: GoogleFonts.dmSans(
                  color: AppColors.textDark, fontSize: 12, height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // WhatsApp version
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF075E54).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF075E54).withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('WHATSAPP VERSION', style: GoogleFonts.dmSans(
                    color: const Color(0xFF128C7E), fontSize: 10,
                    fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _copy(context, alert.pitchTemplate.whatsappVersion, 'WhatsApp message'),
                    child: const Icon(Icons.copy_rounded, color: Color(0xFF128C7E), size: 16),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(alert.pitchTemplate.whatsappVersion, style: GoogleFonts.dmSans(
                  color: AppColors.textDark, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _RefreshButton(onTap: () => ref.read(launchProvider.notifier).fetchBrandAlert()),
        ],
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final BrandOpportunity brand;
  const _BrandCard({required this.brand});

  Color get _fitColor => brand.fitScore >= 90
      ? AppColors.rising
      : brand.fitScore >= 80
          ? AppColors.primary
          : AppColors.textMid;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(brand.brand, style: GoogleFonts.dmSans(
                  color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 15)),
                Text(brand.category, style: GoogleFonts.dmSans(
                  color: AppColors.textMid, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${brand.fitScore}%', style: GoogleFonts.dmSans(
                color: _fitColor, fontWeight: FontWeight.w700, fontSize: 14)),
              Text('fit', style: GoogleFonts.dmSans(color: AppColors.textMid, fontSize: 10)),
            ],
          ),
        ]),
        const SizedBox(height: 10),
        Text(brand.timing, style: GoogleFonts.dmSans(
          color: AppColors.textMid, fontSize: 12, height: 1.4)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.rising.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(brand.estimatedDeal, style: GoogleFonts.dmSans(
            color: AppColors.rising, fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ],
    ),
  );
}

class _CopyableRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;
  const _CopyableRow({required this.label, required this.value, required this.onCopy});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(
            color: AppColors.textMid, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.dmSans(
            color: AppColors.textDark, fontSize: 13)),
        ],
      )),
      GestureDetector(
        onTap: onCopy,
        child: const Icon(Icons.copy_rounded, color: AppColors.textMid, size: 16),
      ),
    ]),
  );
}

// ─── Shared widgets ───────────────────────────────────────────────────────────
class _ARIACard extends StatelessWidget {
  final String text;
  const _ARIACard({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('✨', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: GoogleFonts.dmSans(
          color: AppColors.textDark, fontSize: 13, height: 1.5))),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(label, style: GoogleFonts.dmSans(
    color: AppColors.textMid, fontSize: 11,
    fontWeight: FontWeight.w700, letterSpacing: 1.5));
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(
          color: AppColors.textMid, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.dmSans(
          color: AppColors.textDark, fontSize: 13, height: 1.4)),
      ],
    ),
  );
}

class _RefreshButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RefreshButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 16),
        const SizedBox(width: 6),
        Text('Regenerate', style: GoogleFonts.dmSans(
          color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    ),
  );
}

class _Loading extends StatelessWidget {
  final String message;
  const _Loading(this.message);

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          color: AppColors.primary, strokeWidth: 2),
        const SizedBox(height: 16),
        Text(message, style: GoogleFonts.dmSans(
          color: AppColors.textMid, fontSize: 14)),
      ],
    ),
  );
}

class _Error extends StatelessWidget {
  final VoidCallback onRetry;
  const _Error({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('⚠️', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 12),
        Text('Something went wrong', style: GoogleFonts.dmSans(
          color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Check your connection and try again', style: GoogleFonts.dmSans(
          color: AppColors.textMid, fontSize: 13)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onRetry,
          child: Text('Retry', style: GoogleFonts.dmSans(
            color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      ],
    ),
  );
}
