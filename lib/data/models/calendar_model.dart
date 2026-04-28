// lib/data/models/calendar_model.dart

class CalendarDayModel {
  final String date;        // "2025-01-15"
  final String dayOfWeek;
  final bool isPostingDay;
  final String contentType; // "Reel", "Carousel", "Story", "Live", "Short"
  final String title;
  final String hook;
  final List<String> hashtags;
  final String bestTime;    // "7:30 PM IST"
  final String badge;       // "TRENDING", "FESTIVAL", "PLANNED", "AI_PICK"
  final String? festivalTag;
  final String estimatedReach;
  final String priority;    // "HIGH", "MEDIUM", "LOW"

  const CalendarDayModel({
    required this.date,
    required this.dayOfWeek,
    required this.isPostingDay,
    required this.contentType,
    required this.title,
    required this.hook,
    required this.hashtags,
    required this.bestTime,
    required this.badge,
    this.festivalTag,
    required this.estimatedReach,
    required this.priority,
  });

  factory CalendarDayModel.fromMap(Map<String, dynamic> map) {
    return CalendarDayModel(
      date: map['date'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      isPostingDay: map['isPostingDay'] ?? false,
      contentType: map['contentType'] ?? 'Reel',
      title: map['title'] ?? '',
      hook: map['hook'] ?? '',
      hashtags: List<String>.from(map['hashtags'] ?? []),
      bestTime: map['bestTime'] ?? '7:00 PM IST',
      badge: map['badge'] ?? 'PLANNED',
      festivalTag: map['festivalTag'],
      estimatedReach: map['estimatedReach'] ?? '10K–50K',
      priority: map['priority'] ?? 'MEDIUM',
    );
  }

  Map<String, dynamic> toMap() => {
        'date': date,
        'dayOfWeek': dayOfWeek,
        'isPostingDay': isPostingDay,
        'contentType': contentType,
        'title': title,
        'hook': hook,
        'hashtags': hashtags,
        'bestTime': bestTime,
        'badge': badge,
        'festivalTag': festivalTag,
        'estimatedReach': estimatedReach,
        'priority': priority,
      };
}

class CalendarModel {
  final String month;
  final int totalPosts;
  final int weeklyGoal;
  final String monthTheme;
  final String ariaInsight;
  final List<CalendarDayModel> days;
  final List<String> topWeeks;

  const CalendarModel({
    required this.month,
    required this.totalPosts,
    required this.weeklyGoal,
    required this.monthTheme,
    required this.ariaInsight,
    required this.days,
    required this.topWeeks,
  });

  factory CalendarModel.fromMap(Map<String, dynamic> map) {
    return CalendarModel(
      month: map['month'] ?? '',
      totalPosts: (map['totalPosts'] as num?)?.toInt() ?? 20,
      weeklyGoal: (map['weeklyGoal'] as num?)?.toInt() ?? 5,
      monthTheme: map['monthTheme'] ?? '',
      ariaInsight: map['aria_insight'] ?? map['ariaInsight'] ?? '',
      days: (map['days'] as List<dynamic>? ?? [])
          .map((d) => CalendarDayModel.fromMap(d as Map<String, dynamic>))
          .toList(),
      topWeeks: List<String>.from(map['topWeeks'] ?? []),
    );
  }
}
