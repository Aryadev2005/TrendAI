// lib/core/services/revenue_cat_service.dart
// ARIA — RevenueCat integration service
// Add to pubspec.yaml: purchases_flutter: ^7.0.0

import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  // ── Replace with your actual RevenueCat API keys from dashboard ──
  static const String _iosApiKey = 'appl_your_revenuecat_ios_key_here';
  static const String _androidApiKey = 'goog_your_revenuecat_android_key_here';

  // Entitlement ID — must match exactly what you create in RevenueCat dashboard
  static const String proEntitlementId = 'pro';

  // Offering ID — 'default' unless you create a custom one
  static const String offeringId = 'default';

  // Product IDs — must match App Store Connect / Play Console
  static const String monthlyProductId = 'aria_pro_monthly_499';
  static const String annualProductId = 'aria_pro_annual_5000';

  /// Call once in main() before runApp()
  static Future<void> init({String? userId}) async {
    final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;

    await Purchases.setLogLevel(LogLevel.debug);

    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);

    // Link to Firebase UID so purchases survive reinstalls
    if (userId != null) {
      await Purchases.logIn(userId);
    }
  }

  /// Link RevenueCat to Firebase UID after login
  static Future<void> identifyUser(String firebaseUid) async {
    try {
      await Purchases.logIn(firebaseUid);
    } catch (_) {}
  }

  /// Get current customer info (subscription status)
  static Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }

  /// Check if user has active Pro entitlement
  static Future<bool> isPro() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(proEntitlementId);
    } catch (_) {
      return false;
    }
  }

  /// Fetch packages from the default offering
  static Future<List<Package>> getPackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.getOffering(offeringId) ?? offerings.current;
      return offering?.availablePackages ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Purchase a specific package
  static Future<CustomerInfo> purchasePackage(Package package) async {
    return await Purchases.purchasePackage(package);
  }

  /// Restore purchases (required by App Store guidelines)
  static Future<CustomerInfo> restorePurchases() async {
    return await Purchases.restorePurchases();
  }

  /// Reset on logout
  static Future<void> logout() async {
    try {
      await Purchases.logOut();
    } catch (_) {}
  }
}
