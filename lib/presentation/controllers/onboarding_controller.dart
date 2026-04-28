// lib/presentation/controllers/onboarding_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/aria_profile_model.dart';
import '../../data/repositories/onboarding_repository.dart';

enum OnboardingStep { platformSelect, handleInput, scraping, analysis, nicheConfirm, done }

class OnboardingState {
  final OnboardingStep step;
  final String? selectedPlatform;
  final String? handle;
  final bool isLoading;
  final String? error;
  final ARIAProfileAnalysis? profile;
  // Niche confirm state
  final List<String> confirmedNiches;
  final String? confirmedArchetype;

  const OnboardingState({
    this.step             = OnboardingStep.platformSelect,
    this.selectedPlatform,
    this.handle,
    this.isLoading        = false,
    this.error,
    this.profile,
    this.confirmedNiches  = const [],
    this.confirmedArchetype,
  });

  OnboardingState copyWith({
    OnboardingStep? step,
    String? selectedPlatform,
    String? handle,
    bool? isLoading,
    String? error,
    ARIAProfileAnalysis? profile,
    List<String>? confirmedNiches,
    String? confirmedArchetype,
  }) => OnboardingState(
    step:               step               ?? this.step,
    selectedPlatform:   selectedPlatform   ?? this.selectedPlatform,
    handle:             handle             ?? this.handle,
    isLoading:          isLoading          ?? this.isLoading,
    error:              error,
    profile:            profile            ?? this.profile,
    confirmedNiches:    confirmedNiches    ?? this.confirmedNiches,
    confirmedArchetype: confirmedArchetype ?? this.confirmedArchetype,
  );
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final OnboardingRepository _repo;
  OnboardingNotifier(this._repo) : super(const OnboardingState());

  void selectPlatform(String platform) {
    state = state.copyWith(
      selectedPlatform: platform,
      step: OnboardingStep.handleInput,
    );
  }

  void setHandle(String handle) {
    state = state.copyWith(handle: handle);
  }

  /// Main action: submit handle → scrape → analyse
  Future<void> connectAndAnalyse() async {
    if (state.handle == null || state.selectedPlatform == null) return;

    state = state.copyWith(isLoading: true, step: OnboardingStep.scraping, error: null);

    try {
      final profile = await _repo.connectHandle(
        handle:   state.handle!.replaceAll('@', '').trim(),
        platform: state.selectedPlatform!.toLowerCase(),
      );

      state = state.copyWith(
        isLoading:          false,
        profile:            profile,
        step:               OnboardingStep.analysis,
        confirmedNiches:    profile.detectedNiches,
        confirmedArchetype: profile.archetype,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error:     e.toString(),
        step:      OnboardingStep.handleInput,
      );
    }
  }

  void proceedToNicheConfirm() {
    state = state.copyWith(step: OnboardingStep.nicheConfirm);
  }

  void toggleNiche(String niche) {
    final current = List<String>.from(state.confirmedNiches);
    if (current.contains(niche)) {
      if (current.length > 1) current.remove(niche); // keep at least 1
    } else {
      current.add(niche);
    }
    state = state.copyWith(confirmedNiches: current);
  }

  void setArchetype(String archetype) {
    state = state.copyWith(confirmedArchetype: archetype);
  }

  /// Final step: lock in niche → go to Discover
  Future<void> finaliseAndComplete() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.finaliseNiche(
        confirmedNiches:    state.confirmedNiches,
        confirmedArchetype: state.confirmedArchetype ?? 'EDUCATOR',
        platform:           state.selectedPlatform ?? 'instagram',
        followerRange:      state.profile?.followerRange ?? '1K–10K',
      );
      state = state.copyWith(isLoading: false, step: OnboardingStep.done);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void retry() {
    state = state.copyWith(step: OnboardingStep.handleInput, error: null);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final repo = ref.watch(onboardingRepositoryProvider);
  return OnboardingNotifier(repo);
});
