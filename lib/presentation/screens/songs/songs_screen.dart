import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../data/models/song_model.dart';
import '../../../presentation/controllers/song_controller.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';

class SongsScreen extends ConsumerStatefulWidget {
  const SongsScreen({super.key});

  @override
  ConsumerState<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends ConsumerState<SongsScreen> {
  String _selectedFilter = 'All';
  final _filters = ['All', 'HOT', 'RISING', 'NEW'];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(songProvider.notifier).fetchSongs(niche: 'fashion'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final songState = ref.watch(songProvider);
    final songs = _selectedFilter == 'All'
        ? songState.songs
        : songState.songs.where((s) => s.badge == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                _filterRow(),
                Expanded(
                  child: songState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : songs.isEmpty
                          ? _emptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                              itemCount: songs.length,
                              itemBuilder: (_, i) => _SongCard(song: songs[i]),
                            ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNav(currentIndex: 2),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingLG,
        AppDimensions.paddingLG,
        AppDimensions.paddingLG,
        AppDimensions.paddingSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Song Intelligence',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: AppDimensions.fontXL,
                      color: AppColors.textDark,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Trending audio for Indian creators',
                    style: GoogleFonts.dmSans(
                      fontSize: AppDimensions.fontXS,
                      color: AppColors.textMid,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _aiInsightBanner(),
        ],
      ),
    );
  }

  Widget _aiInsightBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Songs with 15-sec hooks under 100 BPM are getting 2.8x more Reel saves this week',
              style: GoogleFonts.dmSans(
                fontSize: AppDimensions.fontXS,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingLG, 0, AppDimensions.paddingLG, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((f) {
            final selected = _selectedFilter == f;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.bgCard,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  f,
                  style: GoogleFonts.dmSans(
                    color: selected ? Colors.white : AppColors.textMid,
                    fontSize: AppDimensions.fontSM,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_off_rounded,
              size: 48, color: AppColors.textLight.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            'No songs found',
            style: GoogleFonts.dmSans(
                color: AppColors.textMid, fontSize: AppDimensions.fontMD),
          ),
        ],
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  final SongModel song;
  const _SongCard({required this.song});

  Color get _badgeColor {
    switch (song.badge) {
      case 'HOT':
        return AppColors.hot;
      case 'RISING':
        return AppColors.rising;
      default:
        return AppColors.newBadge;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topRow(),
          const SizedBox(height: 6),
          _metaRow(),
          const SizedBox(height: 10),
          _aiTipBox(),
        ],
      ),
    );
  }

  Widget _topRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          child: const Icon(
            Icons.music_note_rounded,
            color: AppColors.accent,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: GoogleFonts.dmSans(
                  color: AppColors.textDark,
                  fontSize: AppDimensions.fontMD,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                song.artist,
                style: GoogleFonts.dmSans(
                  color: AppColors.textMid,
                  fontSize: AppDimensions.fontSM,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _badgeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(color: _badgeColor.withOpacity(0.35)),
          ),
          child: Text(
            song.badge,
            style: GoogleFonts.dmSans(
              color: _badgeColor,
              fontSize: AppDimensions.fontXS,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _metaRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _chip(Icons.play_circle_outline_rounded, song.useCount),
        _chip(Icons.trending_up_rounded, song.growthPercent,
            color: AppColors.rising),
        _chip(Icons.speed_rounded, '${song.bpm} BPM'),
        _chip(Icons.smartphone_rounded, song.platform),
      ],
    );
  }

  Widget _chip(IconData icon, String label, {Color? color}) {
    final c = color ?? AppColors.textMid;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: c),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: AppDimensions.fontXS,
              color: c,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiTipBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 13),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              song.aiTip,
              style: GoogleFonts.dmSans(
                color: AppColors.primaryDark,
                fontSize: AppDimensions.fontXS,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
