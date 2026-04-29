// lib/presentation/controllers/profile_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileState {
  final bool profileLoading;
  final bool analyticsLoading;
  final bool refreshing;
  final CreatorProfile? profile;
  final CreatorAnalytics? analytics;
  final String? error;
  final int activeTab; // 0=Overview 1=Analytics 2=Account

  const ProfileState({
    this.profileLoading   = false,
    this.analyticsLoading = false,
    this.refreshing       = false,
    this.profile,
    this.analytics,
    this.error,
    this.activeTab        = 0,
  });

  ProfileState copyWith({
    bool? profileLoading, bool? analyticsLoading, bool? refreshing,
    CreatorProfile? profile, CreatorAnalytics? analytics,
    String? error, int? activeTab,
  }) => ProfileState(
    profileLoading:   profileLoading   ?? this.profileLoading,
    analyticsLoading: analyticsLoading ?? this.analyticsLoading,
    refreshing:       refreshing       ?? this.refreshing,
    profile:          profile          ?? this.profile,
    analytics:        analytics        ?? this.analytics,
    error:            error,
    activeTab:        activeTab        ?? this.activeTab,
  );

  bool get isLoading => profileLoading || analyticsLoading;
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repo;
  ProfileNotifier(this._repo) : super(const ProfileState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(profileLoading: true, analyticsLoading: true, error: null);
    // Load both in parallel
    await Future.wait([_loadProfile(), _loadAnalytics()]);
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repo.getProfile();
      state = state.copyWith(profileLoading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(profileLoading: false, error: e.toString());
    }
  }

  Future<void> _loadAnalytics() async {
    try {
      final analytics = await _repo.getAnalytics();
      state = state.copyWith(analyticsLoading: false, analytics: analytics);
    } catch (e) {
      state = state.copyWith(analyticsLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(refreshing: true, error: null);
    try {
      final analytics = await _repo.refreshAnalytics();
      state = state.copyWith(refreshing: false, analytics: analytics);
    } catch (e) {
      state = state.copyWith(refreshing: false, error: e.toString());
    }
  }

  void setTab(int tab) => state = state.copyWith(activeTab: tab);
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.watch(profileRepositoryProvider));
});
