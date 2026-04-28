// lib/presentation/controllers/discover_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/radar_model.dart';
import '../../data/repositories/discover_repository.dart';

// ─── State ────────────────────────────────────────────────────────────────
class DiscoverState {
  final bool isLoading;
  final String? error;
  final RadarIntelligence? intelligence;
  final String selectedNiche;   // niche chip selection
  final String selectedBadge;   // HOT | RISING | NEW | ALL

  const DiscoverState({
    this.isLoading   = false,
    this.error,
    this.intelligence,
    this.selectedNiche = 'All',
    this.selectedBadge = 'ALL',
  });

  DiscoverState copyWith({
    bool? isLoading,
    String? error,
    RadarIntelligence? intelligence,
    String? selectedNiche,
    String? selectedBadge,
  }) => DiscoverState(
    isLoading:      isLoading      ?? this.isLoading,
    error:          error          ?? this.error,
    intelligence:   intelligence   ?? this.intelligence,
    selectedNiche:  selectedNiche  ?? this.selectedNiche,
    selectedBadge:  selectedBadge  ?? this.selectedBadge,
  );

  List<RadarOpportunity> get filteredOpportunities {
    if (intelligence == null) return [];
    var ops = intelligence!.opportunities;
    if (selectedBadge != 'ALL') {
      ops = ops.where((o) => o.badge == selectedBadge).toList();
    }
    return ops;
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────
class DiscoverNotifier extends StateNotifier<DiscoverState> {
  final DiscoverRepository _repo;
  DiscoverNotifier(this._repo) : super(const DiscoverState());

  Future<void> fetchIntelligence() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final intel = await _repo.getIntelligence();
      state = state.copyWith(isLoading: false, intelligence: intel);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectBadge(String badge) {
    state = state.copyWith(selectedBadge: badge);
  }

  void selectNiche(String niche) {
    state = state.copyWith(selectedNiche: niche);
  }

  void retry() => fetchIntelligence();
}

// ─── Provider ─────────────────────────────────────────────────────────────
final discoverProvider = StateNotifierProvider<DiscoverNotifier, DiscoverState>((ref) {
  final repo = ref.watch(discoverRepositoryProvider);
  return DiscoverNotifier(repo);
});
