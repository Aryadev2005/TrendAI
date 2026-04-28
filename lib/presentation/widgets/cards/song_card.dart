import 'package:flutter/material.dart';
import '../../../data/models/song_model.dart';

class SongCard extends StatelessWidget {
  final SongModel song;
  final VoidCallback? onTap;

  const SongCard({
    super.key,
    required this.song,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F2), // bgCard
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEDE8DC), // bgSurface
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // ── Rank Number ──────────────────────────────
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _signalColor(song.signal).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  song.badge,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _signalColor(song.signal),
                    fontFamily: 'DMSans',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Song Info ────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C1810), // textDark
                      fontFamily: 'DMSans',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8B6B55), // textMid
                      fontFamily: 'DMSans',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Lifecycle Bar ──────────────────────
                  _LifecycleBar(lifecycle: song.lifecycle),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── Signal Badge ─────────────────────────────
            _SignalBadge(signal: song.signal),
          ],
        ),
      ),
    );
  }

  Color _signalColor(String? signal) {
    switch (signal?.toLowerCase()) {
      case 'postnow':
        return const Color(0xFF6BAF7A); // rising green
      case 'postsoon':
        return const Color(0xFFE8722A); // primary orange
      case 'avoid':
        return const Color(0xFFD05050); // error red
      default:
        return const Color(0xFF8B6B55);
    }
  }
}

// ── Lifecycle Bar ──────────────────────────────────────────
class _LifecycleBar extends StatelessWidget {
  final String? lifecycle;

  const _LifecycleBar({this.lifecycle});

  @override
  Widget build(BuildContext context) {
    final stages = ['early', 'rising', 'peak', 'declining'];
    final currentIndex = stages.indexOf(lifecycle?.toLowerCase() ?? 'rising');

    return Row(
      children: List.generate(stages.length, (i) {
        final isActive = i <= currentIndex;
        final isCurrent = i == currentIndex;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < stages.length - 1 ? 3 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive
                  ? isCurrent
                      ? const Color(0xFFE8722A) // primary orange for current
                      : const Color(0xFFD4956A) // accent for past
                  : const Color(0xFFEDE8DC),   // bgSurface for future
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ── Signal Badge ───────────────────────────────────────────
class _SignalBadge extends StatelessWidget {
  final String? signal;

  const _SignalBadge({this.signal});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (signal?.toLowerCase()) {
      case 'postnow':
        bgColor = const Color(0xFF6BAF7A).withValues(alpha: 0.12);
        textColor = const Color(0xFF6BAF7A);
        label = 'Post Now';
        icon = Icons.bolt_rounded;
        break;
      case 'postsoon':
        bgColor = const Color(0xFFE8722A).withValues(alpha: 0.12);
        textColor = const Color(0xFFE8722A);
        label = 'Post Soon';
        icon = Icons.schedule_rounded;
        break;
      case 'avoid':
        bgColor = const Color(0xFFD05050).withValues(alpha: 0.12);
        textColor = const Color(0xFFD05050);
        label = 'Avoid';
        icon = Icons.do_not_disturb_rounded;
        break;
      default:
        bgColor = const Color(0xFFEDE8DC);
        textColor = const Color(0xFF8B6B55);
        label = 'Watch';
        icon = Icons.visibility_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
              fontFamily: 'DMSans',
            ),
          ),
        ],
      ),
    );
  }
}