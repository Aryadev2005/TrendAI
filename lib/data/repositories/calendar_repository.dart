// lib/data/repositories/calendar_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calendar_model.dart';

class CalendarRepository {
  // Change to your backend URL: http://localhost:3000 for dev, https://api.trendai.in for prod
  static const _baseUrl = 'http://localhost:3000/api/v1';

  Future<CalendarModel> generateCalendar({
    required String niche,
    required String platform,
    required String followerRange,
    required String month,
    required int year,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/calendar/generate'),
        headers: {
          'Content-Type': 'application/json',
          // Add your auth token header here if needed
        },
        body: jsonEncode({
          'niche': niche,
          'platform': platform,
          'followerRange': followerRange,
          'month': month,
          'year': year,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final calendarData = body['data'];
        return CalendarModel.fromMap(calendarData as Map<String, dynamic>);
      } else {
        throw Exception('Failed to generate calendar: ${response.body}');
      }
    } catch (_) {
      // Fallback to mock data if backend unreachable
      return _mockCalendar(month, year, niche);
    }
  }

  CalendarModel _mockCalendar(String month, int year, String niche) {
    final days = <CalendarDayModel>[];

    // Generate posting days: Mon, Wed, Fri, Sat = 4-5 posts/week
    final daysInMonth = DateTime(year,
        [
              'January', 'February', 'March', 'April', 'May', 'June',
              'July', 'August', 'September', 'October', 'November', 'December'
            ].indexOf(month) +
            2,
        0).day;

    final postingWeekdays = {1, 3, 5, 6}; // Mon, Wed, Fri, Sat
    final indianFestivals = _getIndianFestivals(month);

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year,
          [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
          ].indexOf(month) +
              1,
          d);
      final dateStr =
          '$year-${date.month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
      final isPosting = postingWeekdays.contains(date.weekday % 7);
      final festival = indianFestivals[d];

      if (isPosting || festival != null) {
        days.add(CalendarDayModel(
          date: dateStr,
          dayOfWeek: _weekdayName(date.weekday),
          isPostingDay: true,
          contentType: festival != null ? 'Reel' : _contentTypeForDay(date.weekday),
          title: festival ?? _mockTitle(niche, d),
          hook: _mockHook(niche),
          hashtags: _mockHashtags(niche, festival),
          bestTime: '7:30 PM IST',
          badge: festival != null ? 'FESTIVAL' : 'PLANNED',
          festivalTag: festival,
          estimatedReach: '25K–100K',
          priority: festival != null ? 'HIGH' : 'MEDIUM',
        ));
      } else {
        days.add(CalendarDayModel(
          date: dateStr,
          dayOfWeek: _weekdayName(date.weekday),
          isPostingDay: false,
          contentType: '',
          title: '',
          hook: '',
          hashtags: [],
          bestTime: '',
          badge: '',
          festivalTag: null,
          estimatedReach: '',
          priority: 'LOW',
        ));
      }
    }

    return CalendarModel(
      month: '$month $year',
      totalPosts: days.where((d) => d.isPostingDay).length,
      weeklyGoal: 5,
      monthTheme: 'Build authentic connections through trending $niche content',
      ariaInsight:
          'Your audience is most active on weekends. Plan a Live session on Saturday to boost engagement.',
      days: days,
      topWeeks: [
        'Week 2: Focus on educational carousels',
        'Week 3: Festival surge — go all in on cultural content',
      ],
    );
  }

  Map<int, String> _getIndianFestivals(String month) {
    final festivals = <String, Map<int, String>>{
      'January': {14: 'Makar Sankranti', 26: 'Republic Day'},
      'February': {14: 'Valentine\'s Day', 19: 'Shivaji Jayanti'},
      'March': {
        22: 'Holi',
        30: 'Ram Navami',
        8: 'Women\'s Day'
      }, // Holi varies — approximate
      'April': {14: 'Ambedkar Jayanti', 22: 'Earth Day'},
      'May': {1: 'Labour Day'},
      'June': {21: 'World Music Day'},
      'July': {},
      'August': {
        15: 'Independence Day',
        19: 'Raksha Bandhan',
        26: 'Janmashtami'
      },
      'September': {7: 'Ganesh Chaturthi'},
      'October': {
        2: 'Gandhi Jayanti',
        12: 'Dussehra',
        31: 'Halloween'
      },
      'November': {1: 'Diwali', 14: 'Children\'s Day'},
      'December': {25: 'Christmas', 31: 'New Year\'s Eve'},
    };
    return festivals[month] ?? {};
  }

  String _weekdayName(int weekday) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[(weekday - 1) % 7];
  }

  String _contentTypeForDay(int weekday) {
    switch (weekday % 7) {
      case 1: return 'Reel';
      case 3: return 'Carousel';
      case 5: return 'Reel';
      case 6: return 'Live';
      default: return 'Story';
    }
  }

  String _mockTitle(String niche, int day) {
    final titles = [
      '$niche tips you didn\'t know about',
      'POV: Your $niche transformation',
      'Why every Indian creator needs this',
      '$niche budget guide under ₹500',
      'Day in my life as a $niche creator',
      'Honest review: $niche trends this week',
    ];
    return titles[day % titles.length];
  }

  String _mockHook(String niche) {
    final hooks = [
      'I spent ₹500 and looked like I spent ₹50,000 — here\'s exactly how 👀',
      'Stop scrolling if you love $niche content!',
      'The secret to going viral in India is...',
      '3 mistakes you\'re making in your $niche journey.',
    ];
    return hooks[DateTime.now().millisecond % hooks.length];
  }

  List<String> _mockHashtags(String niche, String? festival) {
    final base = ['#${niche.replaceAll(' ', '')}', '#IndianCreator', '#Reels'];
    if (festival != null) {
      base.add('#${festival.replaceAll(' ', '')}');
    }
    return base;
  }
}
