import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/launch_model.dart';
import '../../data/repositories/launch_repository.dart';
import 'aria_session_controller.dart';

enum LaunchTab { timing, package, brands }

class LaunchState {
  final LaunchTab activeTab;

  // Timing
  final bool timingLoading;
  final TimingIntelligence? timing;

  // Posting package
  final bool packageLoading;
  final PostingPackage? package;

  // Brand alert
  final bool brandsLoading;
  final BrandAlert? brandAlert;

  // Shared
  final String? error;

  const LaunchState({
    this.activeTab     = LaunchTab.timing,
    this.timingLoading = false,
    this.timing,
    this.packageLoading = false,
    this.package,
    this.brandsLoading  = false,
    this.brandAlert,
    this.error,
  });

  LaunchState copyWith({
    LaunchTab? activeTab,
    bool? timingLoading,
    TimingIntelligence? timing,
    bool? packageLoading,
    PostingPackage? package,
    bool? brandsLoading,
    BrandAlert? brandAlert,
    String? error,
  }) => LaunchState(
    activeTab:      activeTab      ?? this.activeTab,
    timingLoading:  timingLoading  ?? this.timingLoading,
    timing:         timing         ?? this.timing,
    packageLoading: packageLoading ?? this.packageLoading,
    package:        package        ?? this.package,
    brandsLoading:  brandsLoading  ?? this.brandsLoading,
    brandAlert:     brandAlert     ?? this.brandAlert,
    error:          error,
  );

  bool get isAnyLoading => timingLoading || packageLoading || brandsLoading;
}

class LaunchNotifier extends StateNotifier<LaunchState> {
  final LaunchRepository _repo;
  final AriaSession _session;

  LaunchNotifier(this._repo, this._session) : super(const LaunchState()) {
    // Auto-load timing on init
    fetchTiming();
  }

  void setTab(LaunchTab tab) => state = state.copyWith(activeTab: tab);

  Future<void> fetchTiming() async {
    state = state.copyWith(timingLoading: true, error: null);
    try {
      debugPrint('[LaunchNotifier] fetchTiming() started');
      final timing = await _repo.getTimingIntelligence();
      debugPrint('[LaunchNotifier] fetchTiming() success: ${timing.nextBestSlot}');
      state = state.copyWith(timingLoading: false, timing: timing);
    } catch (e) {
      debugPrint('[LaunchNotifier] fetchTiming() error: $e');
      state = state.copyWith(timingLoading: false, error: e.toString());
    }
  }

  Future<void> fetchPostingPackage() async {
    state = state.copyWith(packageLoading: true, error: null);
    try {
      debugPrint('[LaunchNotifier] fetchPostingPackage() started with idea="${_session.idea}"');
      final pkg = await _repo.getPostingPackage(
        idea:   _session.idea,
        script: _session.script,
      );
      debugPrint('[LaunchNotifier] fetchPostingPackage() success: ${pkg.caption.substring(0, 50)}...');
      state = state.copyWith(packageLoading: false, package: pkg);
    } catch (e) {
      debugPrint('[LaunchNotifier] fetchPostingPackage() error: $e');
      state = state.copyWith(packageLoading: false, error: e.toString());
    }
  }

  Future<void> fetchBrandAlert() async {
    state = state.copyWith(brandsLoading: true, error: null);
    try {
      debugPrint('[LaunchNotifier] fetchBrandAlert() started');
      final alert = await _repo.getBrandAlert();
      debugPrint('[LaunchNotifier] fetchBrandAlert() success: ${alert.brandOpportunities.length} brands found');
      state = state.copyWith(brandsLoading: false, brandAlert: alert);
    } catch (e) {
      debugPrint('[LaunchNotifier] fetchBrandAlert() error: $e');
      state = state.copyWith(brandsLoading: false, error: e.toString());
    }
  }

  void retryCurrentTab() {
    switch (state.activeTab) {
      case LaunchTab.timing:   fetchTiming();        break;
      case LaunchTab.package:  fetchPostingPackage(); break;
      case LaunchTab.brands:   fetchBrandAlert();    break;
    }
  }
}

final launchProvider = StateNotifierProvider<LaunchNotifier, LaunchState>((ref) {
  final repo    = ref.watch(launchRepositoryProvider);
  final session = ref.watch(ariaSessionProvider);
  return LaunchNotifier(repo, session);
});
