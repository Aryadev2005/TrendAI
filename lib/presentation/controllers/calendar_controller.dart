import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/calendar_model.dart';
import '../../data/repositories/calendar_repository.dart';
import 'auth_controller.dart';

class CalendarState {
  final CalendarModel? calendar;
  final bool isLoading;
  final String? error;
  const CalendarState({this.calendar, this.isLoading = false, this.error});
  CalendarState copyWith({CalendarModel? calendar, bool? isLoading, String? error}) {
    return CalendarState(
      calendar: calendar ?? this.calendar,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CalendarController extends StateNotifier<CalendarState> {
  final CalendarRepository _repo;
  final Ref _ref;
  CalendarController(this._repo, this._ref) : super(const CalendarState());

  Future<void> generateCalendar({
    required String month,
    required int year,
    String? niche,
    String? platform,
    String? followerRange,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = _ref.read(authProvider).user;
      final effectiveNiche = niche ??
          (user?.niches.isNotEmpty == true
              ? user!.niches.first.replaceAll(RegExp(r'[^\w\s]'), '').trim()
              : 'Fashion');
      final effectivePlatform = platform ?? user?.primaryPlatform ?? 'Instagram';
      final effectiveFollowerRange = followerRange ?? user?.followerRange ?? '10K-50K';
      final calendar = await _repo.generateCalendar(
        niche: effectiveNiche,
        platform: effectivePlatform,
        followerRange: effectiveFollowerRange,
        month: month,
        year: year,
      );
      state = state.copyWith(calendar: calendar, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearCalendar() => state = const CalendarState();
}

final calendarRepositoryProvider = Provider((ref) => CalendarRepository());

final calendarProvider = StateNotifierProvider<CalendarController, CalendarState>(
  (ref) => CalendarController(ref.read(calendarRepositoryProvider), ref),
);