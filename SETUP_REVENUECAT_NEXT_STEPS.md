# ✅ RevenueCat Integration Checklist

## What Was Done

### Core Files Created
- ✅ `lib/core/services/revenue_cat_service.dart` — RevenueCat SDK wrapper
- ✅ `lib/data/repositories/subscription_repository.dart` — Subscription logic & backend sync
- ✅ `lib/presentation/controllers/subscription_controller.dart` — Riverpod state management
- ✅ `lib/presentation/screens/subscription/paywall_screen.dart` — Paywall UI
- ✅ `lib/presentation/widgets/pro_gate.dart` — Pro gating widget & ProBadge

### Existing Files Modified
- ✅ `pubspec.yaml` — Added `purchases_flutter: ^7.0.0`
- ✅ `lib/main.dart` — Initialize RevenueCat with Firebase UID
- ✅ `lib/routes/app_routes.dart` — Added `/paywall` route
- ✅ `lib/presentation/screens/profile/profile_screen.dart` — Added "Upgrade to Pro" menu & made subscription card tappable

## What You Need to Do

### 🔴 CRITICAL - API Keys
1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Create applications for iOS and Android
3. Copy your API keys
4. Update `lib/core/services/revenue_cat_service.dart`:
   - Line 10: Replace `appl_your_revenuecat_ios_key_here` with your iOS key
   - Line 11: Replace `goog_your_revenuecat_android_key_here` with your Android key

### 🔴 CRITICAL - In-App Products
1. **iOS (App Store Connect)**
   - Create product: `aria_pro_monthly_499` → ₹499/month
   - Create product: `aria_pro_annual_5000` → ₹5,000/year

2. **Android (Google Play Console)**
   - Create product: `aria_pro_monthly_499` → ₹499/month
   - Create product: `aria_pro_annual_5000` → ₹5,000/year

3. **RevenueCat**
   - Link products from both stores
   - Verify they appear in the "default" offering

### 🟡 OPTIONAL - Backend Sync
Update endpoint in `lib/data/repositories/subscription_repository.dart` (line 12):
```dart
static const String _baseUrl = 'https://your-api.com'; // Replace with your backend
```

This allows your backend to log purchases, but RevenueCat is the source of truth.

## How to Use in Your App

### Protect a Full Screen
```dart
GoRoute(
  path: AppRoutes.rateCard,
  builder: (_, __) => const ProGate(
    featureName: 'Rate Card Generator',
    child: RateCardScreen(),
  ),
),
```

### Protect a Button
```dart
ProGate.button(
  context: context,
  ref: ref,
  label: 'Generate Rate Card',
  icon: Icons.price_change_outlined,
  featureName: 'Rate Card Generator',
  onProTap: () => context.push(AppRoutes.rateCard),
),
```

### Show Pro Status
```dart
if (user?.isPro == true) ...[
  const ProBadge(),
],
```

## Testing Flow

1. **Run app**: `flutter run`
2. **Login** to your app
3. **Navigate to Profile** → Account tab
4. **Tap "Upgrade to Pro"** → Opens PaywallScreen
5. **Test Monthly/Annual toggle** → Prices should display
6. **Tap purchase button** → RevenueCat dialog appears
7. **Use sandbox account** (TestFlight/beta):
   - iOS: Use sandbox account in Settings
   - Android: Use test account from Google Play Console
8. **Verify Pro status**:
   - Subscription badge appears in profile
   - Protected features unlock
   - Status persists after app restart

## Files Summary

| File | Purpose | Status |
|------|---------|--------|
| `revenue_cat_service.dart` | RevenueCat SDK wrapper | ✅ Created |
| `subscription_repository.dart` | Purchase & sync logic | ✅ Created |
| `subscription_controller.dart` | Riverpod state mgmt | ✅ Created |
| `paywall_screen.dart` | Pro paywall UI | ✅ Created |
| `pro_gate.dart` | Pro gating widget | ✅ Created |
| `pubspec.yaml` | Dependencies | ✅ Updated |
| `main.dart` | RevenueCat init | ✅ Updated |
| `app_routes.dart` | `/paywall` route | ✅ Updated |
| `profile_screen.dart` | "Upgrade" menu + links | ✅ Updated |

## Pricing Info

**Monthly**: ₹499/month
- Product ID: `aria_pro_monthly_499`
- Fallback in code if RevenueCat unavailable

**Annual**: ₹5,000/year (shows as 50% savings vs monthly)
- Product ID: `aria_pro_annual_5000`
- Fallback in code if RevenueCat unavailable

## Error Handling

User sees friendly messages for:
- ❌ Network offline → "No internet connection. Please check and try again."
- ❌ Product unavailable → "This plan is not available in your region yet."
- ❌ Already subscribed → "You already have Pro! Try 'Restore Purchase'."
- ❌ User cancelled → (silent, no message)
- ❌ Generic error → "Something went wrong. Please try again."

## Architecture Highlights

- **RevenueCat = Source of Truth** for subscription status
- **Firebase UID linked** in RevenueCat (survives reinstalls)
- **Riverpod manages state** (UI updates automatically)
- **Backend sync is optional** (non-fatal if fails)
- **Error codes parsed** into user-friendly messages
- **Pro status stored in UserModel** (`isPro` field)
- **Auth state auto-updates** on successful purchase

## Next Steps After Setup

1. ✅ Get RevenueCat API keys
2. ✅ Create in-app products in App Store + Play Console
3. ✅ Link products in RevenueCat dashboard
4. ✅ Update Firebase rules for Pro features (if needed)
5. ✅ Test on iOS + Android with sandbox accounts
6. ✅ Deploy to TestFlight + Internal Testing
7. ✅ Monitor RevenueCat dashboard for purchases
8. ✅ Add ProBadge to more screens (optional)
9. ✅ Gate more features with ProGate (optional)

---

**Last Updated**: April 29, 2026
**Integration Method**: Followed INTEGRATION_GUIDE.dart exactly
**Status**: ✅ Ready for API key configuration
