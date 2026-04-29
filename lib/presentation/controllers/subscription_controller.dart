// lib/presentation/controllers/subscription_controller.dart
// ARIA — Subscription state management (Riverpod)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../data/repositories/subscription_repository.dart';
import './auth_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────

class SubscriptionState {
  final bool isLoading;
  final bool isPro;
  final bool isPurchasing;
  final bool isRestoring;
  final List<Package> packages;
  final String? error;
  final String? successMessage;

  const SubscriptionState({
    this.isLoading = false,
    this.isPro = false,
    this.isPurchasing = false,
    this.isRestoring = false,
    this.packages = const [],
    this.error,
    this.successMessage,
  });

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isPro,
    bool? isPurchasing,
    bool? isRestoring,
    List<Package>? packages,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isPro: isPro ?? this.isPro,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isRestoring: isRestoring ?? this.isRestoring,
      packages: packages ?? this.packages,
      error: clearError ? null : error ?? this.error,
      successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }

  /// Monthly package from RevenueCat offering
  Package? get monthlyPackage {
    try {
      return packages.firstWhere((p) => p.packageType == PackageType.monthly);
    } catch (_) {
      return null;
    }
  }

  /// Annual package from RevenueCat offering
  Package? get annualPackage {
    try {
      return packages.firstWhere((p) => p.packageType == PackageType.annual);
    } catch (_) {
      return null;
    }
  }

  /// Display price for monthly (falls back to ₹499)
  String get monthlyPrice {
    final price = monthlyPackage?.storeProduct.priceString;
    return price ?? '₹499';
  }

  /// Display price for annual (falls back to ₹5,000)
  String get annualPrice {
    final price = annualPackage?.storeProduct.priceString;
    return price ?? '₹5,000';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTROLLER
// ─────────────────────────────────────────────────────────────────────────────

class SubscriptionController extends StateNotifier<SubscriptionState> {
  final SubscriptionRepository _repo;
  final Ref _ref;

  SubscriptionController(this._repo, this._ref)
      : super(const SubscriptionState()) {
    loadSubscription();
  }

  // ── Load current status + packages ──────────────────────────────────────

  Future<void> loadSubscription() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repo.isPro(),
        _repo.getPackages(),
      ]);

      state = state.copyWith(
        isLoading: false,
        isPro: results[0] as bool,
        packages: results[1] as List<Package>,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load subscription info. Please try again.',
      );
    }
  }

  // ── Purchase monthly ₹499/month ──────────────────────────────────────────

  Future<void> purchaseMonthly() async {
    if (state.isPurchasing) return;
    state = state.copyWith(isPurchasing: true, clearError: true);
    try {
      final success = await _repo.purchaseMonthly();
      if (success) {
        state = state.copyWith(
          isPurchasing: false,
          isPro: true,
          successMessage: '🎉 Welcome to ARIA Pro! You\'re all set.',
        );
        _updateAuthState();
      } else {
        state = state.copyWith(
          isPurchasing: false,
          error: 'Purchase could not be completed. Please try again.',
        );
      }
    } catch (e) {
      final msg = _parseError(e.toString());
      state = state.copyWith(isPurchasing: false, error: msg);
    }
  }

  // ── Purchase annual ₹5,000/year ──────────────────────────────────────────

  Future<void> purchaseAnnual() async {
    if (state.isPurchasing) return;
    state = state.copyWith(isPurchasing: true, clearError: true);
    try {
      final success = await _repo.purchaseAnnual();
      if (success) {
        state = state.copyWith(
          isPurchasing: false,
          isPro: true,
          successMessage: '🎉 Welcome to ARIA Pro! Annual plan activated.',
        );
        _updateAuthState();
      } else {
        state = state.copyWith(
          isPurchasing: false,
          error: 'Purchase could not be completed. Please try again.',
        );
      }
    } catch (e) {
      final msg = _parseError(e.toString());
      state = state.copyWith(isPurchasing: false, error: msg);
    }
  }

  // ── Restore purchases ────────────────────────────────────────────────────

  Future<void> restorePurchases() async {
    if (state.isRestoring) return;
    state = state.copyWith(isRestoring: true, clearError: true);
    try {
      final restored = await _repo.restorePurchases();
      if (restored) {
        state = state.copyWith(
          isRestoring: false,
          isPro: true,
          successMessage: '✅ Pro access restored successfully!',
        );
        _updateAuthState();
      } else {
        state = state.copyWith(
          isRestoring: false,
          successMessage: 'No previous purchases found.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isRestoring: false,
        error: 'Could not restore purchases. Please try again.',
      );
    }
  }

  // ── Sync auth state so UI updates immediately ────────────────────────────

  void _updateAuthState() {
    final authState = _ref.read(authProvider);
    if (authState.user != null) {
      _ref.read(authProvider.notifier).state = authState.copyWith(
        user: authState.user!.copyWith(isPro: true),
      );
    }
  }

  // ── Parse RevenueCat error codes into friendly messages ─────────────────

  String _parseError(String raw) {
    if (raw.contains('cancelled') || raw.contains('userCancelled')) {
      return ''; // User cancelled — show nothing
    }
    if (raw.contains('networkError')) {
      return 'No internet connection. Please check and try again.';
    }
    if (raw.contains('productNotAvailable')) {
      return 'This plan is not available in your region yet.';
    }
    if (raw.contains('alreadyPurchased')) {
      return 'You already have Pro! Try "Restore Purchase".';
    }
    return 'Something went wrong. Please try again.';
  }

  void clearError() => state = state.copyWith(clearError: true);
  void clearSuccess() => state = state.copyWith(clearSuccess: true);
}

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

final subscriptionRepositoryProvider = Provider(
  (ref) => SubscriptionRepository(),
);

final subscriptionProvider =
    StateNotifierProvider<SubscriptionController, SubscriptionState>(
  (ref) => SubscriptionController(
    ref.read(subscriptionRepositoryProvider),
    ref,
  ),
);
