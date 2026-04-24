// ignore_for_file: avoid_print
//
// FirebaseService — stub implementation
// ──────────────────────────────────────────────────────────────────────────
// To activate Firebase:
//   1. Run: flutterfire configure
//   2. Uncomment the firebase_core + firebase_auth imports in pubspec.yaml
//   3. Replace stubs below with real Firebase calls
//   4. Add GoogleService-Info.plist (iOS) and google-services.json (Android)
// ──────────────────────────────────────────────────────────────────────────

class FirebaseService {
  static bool _initialized = false;

  /// Call once in main() after WidgetsFlutterBinding.ensureInitialized()
  static Future<void> initialize() async {
    if (_initialized) return;
    // TODO: await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    _initialized = true;
    print('[FirebaseService] stub initialized — real Firebase not yet configured');
  }

  /// Sign in with email + password
  static Future<Map<String, dynamic>?> signInWithEmail(
    String email,
    String password,
  ) async {
    // TODO: final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(...)
    // return {'uid': cred.user!.uid, 'email': cred.user!.email};
    throw UnimplementedError('Firebase Auth not yet configured');
  }

  /// Create account with email + password
  static Future<Map<String, dynamic>?> createAccount(
    String email,
    String password,
    String name,
  ) async {
    // TODO: final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(...)
    // await cred.user!.updateDisplayName(name);
    throw UnimplementedError('Firebase Auth not yet configured');
  }

  /// Sign out
  static Future<void> signOut() async {
    // TODO: await FirebaseAuth.instance.signOut();
  }

  /// Save user document to Firestore
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    // TODO: await FirebaseFirestore.instance.collection('users').doc(userData['id']).set(userData);
  }

  /// Fetch user document from Firestore
  static Future<Map<String, dynamic>?> getUser(String uid) async {
    // TODO: final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    // return doc.data();
    return null;
  }

  /// Save trend to user's saved list
  static Future<void> saveTrend(String userId, String trendId) async {
    // TODO: Firestore update
  }

  /// Get saved trends for user
  static Future<List<String>> getSavedTrends(String userId) async {
    return [];
  }
}
