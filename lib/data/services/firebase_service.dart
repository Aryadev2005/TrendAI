import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  // ─── Auth ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> signInWithEmail(
    String email,
    String password,
  ) async {
    final cred = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return {
      'uid': cred.user!.uid,
      'email': cred.user!.email,
      'name': cred.user!.displayName ?? '',
    };
  }

  static Future<Map<String, dynamic>?> createAccount(
    String email,
    String password,
    String name,
  ) async {
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(name);
    return {
      'uid': cred.user!.uid,
      'email': cred.user!.email,
      'name': name,
    };
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static User? get currentUser => auth.currentUser;

  // ─── Firestore — Users ────────────────────────────────────────────────────

  static Future<void> saveUser(Map<String, dynamic> userData) async {
    await db
        .collection('users')
        .doc(userData['id'])
        .set(userData, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await db.collection('users').doc(uid).get();
    return doc.data();
  }

  static Future<void> updateUser(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await db.collection('users').doc(uid).update(data);
  }

  // ─── Firestore — Trends ───────────────────────────────────────────────────

  static Future<void> saveTrend(
    String userId,
    Map<String, dynamic> trend,
  ) async {
    await db
        .collection('saved_trends')
        .doc(userId)
        .collection('trends')
        .doc(trend['id'])
        .set(trend);
  }

  static Future<List<Map<String, dynamic>>> getSavedTrends(
    String userId,
  ) async {
    final snap = await db
        .collection('saved_trends')
        .doc(userId)
        .collection('trends')
        .orderBy('detectedAt', descending: true)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  // ─── Firestore — Content History ──────────────────────────────────────────

  static Future<void> saveContentHistory(
    String userId,
    Map<String, dynamic> content,
  ) async {
    await db
        .collection('content_history')
        .doc(userId)
        .collection('items')
        .add({
      ...content,
      'userId': userId,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<Map<String, dynamic>>> getContentHistory(
    String userId,
  ) async {
    final snap = await db
        .collection('content_history')
        .doc(userId)
        .collection('items')
        .orderBy('savedAt', descending: true)
        .limit(20)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  // ─── Firestore — Analytics ────────────────────────────────────────────────

  static Future<void> logContentGenerated(
    String userId,
    String platform,
    String niche,
  ) async {
    await db.collection('analytics').add({
      'userId': userId,
      'event': 'content_generated',
      'platform': platform,
      'niche': niche,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}