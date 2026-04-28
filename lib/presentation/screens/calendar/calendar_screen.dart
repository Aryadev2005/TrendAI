import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';
import '../../../presentation/controllers/calendar_controller.dart';
import '../../../data/models/calendar_model.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  int? _selectedDay;

  final _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    Future.microtask(() => ref.read(calendarProvider.notifier).generateCalendar(
          month: _monthNames[_selectedMonth - 1],
          year: _selectedYear,
        ));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth += delta;
      _selectedDay = null;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear--;
      }
    });
    _fadeCtrl.reset();
    _fadeCtrl.forward();
    ref.read(calendarProvider.notifier).generateCalendar(
          month: _monthNames[_selectedMonth - 1],
          year: _selectedYear,
        );
  }
  
  CalendarDayModel? _findDay(CalendarModel cal, String dateStr) {
    final matches = cal.days.where((d) => d.date == dateStr);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 50),
                _header(state),
                Expanded(
                  child: FadeTransition(
                    opacity: _fade,
                    child: state.isLoading
                        ? _loadingState()
                        : state.calendar == null
                            ? _emptyState()
                            : SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _ariaInsightCard(state.calendar!),
                                    const SizedBox(height: 20),
                                    _statsRow(state.calendar!),
                                    const SizedBox(height: 20),
                                    _calendarGrid(state.calendar!),
                                    const SizedBox(height: 20),
                                    if (_selectedDay != null)
                                      _dayDetailCard(state.calendar!, _selectedDay!),
                                  ],
                                ),
                              ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }

  Widget _header(CalendarState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Content Calendar',
                style: GoogleFonts.dmSans(
                  color: AppColors.textDark,
                  fontSize: AppDimensions.fontXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 22),
                      onPressed: () => _changeMonth(-1),
                      color: AppColors.textMid,
                      splashRadius: 20,
                    ),
                    SizedBox(
                      width: 110,
                      child: Text(
                        '${_monthNames[_selectedMonth - 1]} $_selectedYear',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          color: AppColors.textDark,
                          fontSize: AppDimensions.fontSM,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 22),
                      onPressed: () => _changeMonth(1),
                      color: AppColors.textMid,
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (state.calendar != null) ...[
            const SizedBox(height: 12),
            Text(
              state.calendar!.monthTheme,
              style: GoogleFonts.dmSans(
                color: AppColors.textMid,
                fontSize: AppDimensions.fontSM,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ariaInsightCard(CalendarModel cal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                "ARIA's Insight",
                style: GoogleFonts.dmSans(
                  color: AppColors.primary,
                  fontSize: AppDimensions.fontMD,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            cal.ariaInsight,
            style: GoogleFonts.dmSans(
              color: AppColors.textDark,
              fontSize: AppDimensions.fontSM,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(CalendarModel cal) {
    return Row(
      children: [
        _statChip(Icons.post_add_rounded, cal.totalPosts.toString(), 'Posts'),
        const SizedBox(width: 12),
        _statChip(Icons.track_changes_rounded, '${cal.weeklyGoal}/week', 'Goal'),
        const SizedBox(width: 12),
        _statChip(Icons.flag_rounded, cal.topWeeks.first, 'Focus'),
      ],
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.textLight, size: 16),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textDark,
                    fontSize: AppDimensions.fontMD,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: AppColors.textMid,
                fontSize: AppDimensions.fontXS,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendarGrid(CalendarModel cal) {
    final daysInMonth =
        DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final firstWeekday =
        DateTime(_selectedYear, _selectedMonth, 1).weekday % 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Text(d,
                    style: GoogleFonts.dmSans(
                        color: AppColors.textLight,
                        fontSize: AppDimensions.fontXS,
                        fontWeight: FontWeight.bold)))
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: daysInMonth + firstWeekday,
            itemBuilder: (context, index) {
              if (index < firstWeekday) return const SizedBox.shrink();
              final day = index - firstWeekday + 1;
              final dateStr =
                  '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
              final dayData = _findDay(cal, dateStr);

              final isSelected = _selectedDay == day;
              final isToday = day == DateTime.now().day &&
                  _selectedMonth == DateTime.now().month &&
                  _selectedYear == DateTime.now().year;

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: GoogleFonts.dmSans(
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? AppColors.primary
                                  : AppColors.textDark,
                          fontWeight:
                              isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          fontSize: AppDimensions.fontSM,
                        ),
                      ),
                      if (dayData?.isPostingDay ?? false) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.8)
                                : _badgeColor(dayData!.badge),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legendDot(AppColors.accent, 'Trending'),
              _legendDot(AppColors.secondary, 'Festival'),
              _legendDot(AppColors.primary, 'AI Pick'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.dmSans(color: AppColors.textMid, fontSize: 11)),
      ],
    );
  }

  Widget _dayDetailCard(CalendarModel cal, int day) {
    final dateStr =
        '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    final dayData = _findDay(cal, dateStr);

    if (dayData == null || !dayData.isPostingDay) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'Rest day. Time to recharge! 🔋',
            style: GoogleFonts.dmSans(color: AppColors.textMid, fontSize: AppDimensions.fontSM),
          ),
        ),
      );
    }

    final badgeColor = _badgeColor(dayData.badge);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  dayData.badge,
                  style: GoogleFonts.dmSans(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                dayData.dayOfWeek,
                style: GoogleFonts.dmSans(
                  color: AppColors.textLight,
                  fontSize: AppDimensions.fontXS,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dayData.title,
            style: GoogleFonts.dmSans(
              color: AppColors.textDark,
              fontSize: AppDimensions.fontLG,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dayData.hook,
            style: GoogleFonts.dmSans(
              color: AppColors.textMid,
              fontSize: AppDimensions.fontSM,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.smart_display_rounded, 'Content Type', dayData.contentType),
          const SizedBox(height: 10),
          _infoRow(Icons.access_time_filled_rounded, 'Best Time', dayData.bestTime),
          const SizedBox(height: 10),
          _infoRow(Icons.bar_chart_rounded, 'Est. Reach', dayData.estimatedReach),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: dayData.hashtags
                .map((tag) => Chip(
                      label: Text(tag, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMid)),
                      backgroundColor: AppColors.bgPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textLight, size: 16),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.dmSans(color: AppColors.textMid, fontSize: AppDimensions.fontSM),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              color: AppColors.textDark,
              fontSize: AppDimensions.fontSM,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'ARIA is planning your month...',
            style: GoogleFonts.dmSans(
              color: AppColors.textMid,
              fontSize: AppDimensions.fontMD,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_view_month_rounded, color: AppColors.textLight, size: 50),
          const SizedBox(height: 16),
          Text(
            'Could not generate calendar',
            style: GoogleFonts.dmSans(
              color: AppColors.textDark,
              fontSize: AppDimensions.fontLG,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              color: AppColors.textMid,
              fontSize: AppDimensions.fontSM,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _fadeCtrl.reset();
              _fadeCtrl.forward();
              ref.read(calendarProvider.notifier).generateCalendar(
                    month: _monthNames[_selectedMonth - 1],
                    year: _selectedYear,
                  );
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _badgeColor(String badge) {
    switch (badge) {
      case 'TRENDING':
        return AppColors.accent;
      case 'FESTIVAL':
        return AppColors.secondary;
      case 'AI_PICK':
        return AppColors.primary;
      default:
        return AppColors.textLight;
    }
  }
}
