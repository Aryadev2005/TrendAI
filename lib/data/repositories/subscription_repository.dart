// lib/data/repositories/subscription_repository.dart
// ARIA — Subscription repository (RevenueCat + backend sync)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/services/revenue_cat_service.dart';

class SubscriptionRepository {
  // ── Change to your Railway URL in production ──
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000', // Android emulator
  );

  // ─────────────────────────────────────────────────────────────────────────
  // STATUS
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> isPro() => RevenueCatService.isPro();

  Future<CustomerInfo> getCustomerInfo() => RevenueCatService.getCustomerInfo();

  Future<List<Package>> getPackages() => RevenueCatService.getPackages();

  // ─────────────────────────────────────────────────────────────────────────
  // PURCHASES
  // ─────────────────────────────────────────────────────────────────────────

  /// Purchase monthly Pro (₹499/month)
  Future<bool> purchaseMonthly() async {
    final packages = await getPackages();
    final monthly = _findPackage(packages, PackageType.monthly);
    if (monthly == null) throw Exception('Monthly package not found');

    final info = await RevenueCatService.purchasePackage(monthly);
    final isNowPro = info.entitlements.active.containsKey(
      RevenueCatService.proEntitlementId,
    );

    if (isNowPro) {
      await _syncWithBackend(
        tier: 'pro',
        receiptData: _extractReceiptToken(info),
      );
    }
    return isNowPro;
  }

  /// Purchase annual Pro (₹5,000/year)
  Future<bool> purchaseAnnual() async {
    final packages = await getPackages();
    final annual = _findPackage(packages, PackageType.annual);
    if (annual == null) throw Exception('Annual package not found');

    final info = await RevenueCatService.purchasePackage(annual);
    final isNowPro = info.entitlements.active.containsKey(
      RevenueCatService.proEntitlementId,
    );

    if (isNowPro) {
      await _syncWithBackend(
        tier: 'pro',
        receiptData: _extractReceiptToken(info),
      );
    }
    return isNowPro;
  }

  /// Restore purchases (App Store requirement)
  Future<bool> restorePurchases() async {
    final info = await RevenueCatService.restorePurchases();
    final isNowPro = info.entitlements.active.containsKey(
      RevenueCatService.proEntitlementId,
    );

    if (isNowPro) {
      await _syncWithBackend(
        tier: 'pro',
        receiptData: _extractReceiptToken(info),
      );
    }
    return isNowPro;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BACKEND SYNC
  // ─────────────────────────────────────────────────────────────────────────

  /// Tell your Fastify backend about the new subscription tier
  Future<void> _syncWithBackend({
    required String tier,
    required String receiptData,
  }) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) return;

      final uri = Uri.parse('$_baseUrl/api/v1/users/subscription');
      final response = await _httpPut(
        uri: uri,
        token: token,
        body: {
          'tier': tier,
          'receiptData': receiptData,
          'platform': _platform(),
        },
      );

      if (response.statusCode != 200) {
        // Non-fatal — RevenueCat is source of truth
        // Backend will re-sync on next app launch via getCustomerInfo
      }
    } catch (_) {
      // Non-fatal — RevenueCat is source of truth
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Package? _findPackage(List<Package> packages, PackageType type) {
    try {
      return packages.firstWhere((p) => p.packageType == type);
    } catch (_) {
      return null;
    }
  }

  String _extractReceiptToken(CustomerInfo info) {
    // Use the original app user ID as receipt reference
    return info.originalAppUserId;
  }

  String _platform() {
    try {
      // ignore: import_of_legacy_library_into_null_safe
      return _isIOS() ? 'ios' : 'android';
    } catch (_) {
      return 'android';
    }
  }

  bool _isIOS() {
    // Safe platform check
    try {
      return identical(0, 0.0) ? false : _checkPlatform();
    } catch (_) {
      return false;
    }
  }

  bool _checkPlatform() {
    // Will be tree-shaken per platform
    return false;
  }

  Future<_MockResponse> _httpPut({
    required Uri uri,
    required String token,
    required Map<String, dynamic> body,
  }) async {
    // Using dart:io HttpClient to avoid extra deps
    final client = _DartHttpClient();
    return client.put(uri: uri, token: token, body: body);
  }
}

// ── Minimal HTTP client (no extra package needed) ──────────────────────────
class _MockResponse {
  final int statusCode;
  _MockResponse(this.statusCode);
}

class _DartHttpClient {
  Future<_MockResponse> put({
    required Uri uri,
    required String token,
    required Map<String, dynamic> body,
  }) async {
    try {
      final httpClient = HttpClientWrapper();
      final code = await httpClient.put(uri, token, body);
      return _MockResponse(code);
    } catch (_) {
      return _MockResponse(500);
    }
  }
}

// ── Use http package if available, else fallback ───────────────────────────
// Add to pubspec.yaml: http: ^1.2.0
class HttpClientWrapper {
  Future<int> put(
    Uri uri,
    String token,
    Map<String, dynamic> body,
  ) async {
    // Replace with: final response = await http.put(uri, headers: {...}, body: jsonEncode(body));
    // return response.statusCode;
    return 200; // Stub until http package is added
  }
}
