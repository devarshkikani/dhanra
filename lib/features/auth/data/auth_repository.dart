import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/local_storage_service.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final LocalStorageService _storage = LocalStorageService();

  // Handle common post-sign-in logic
  Future<void> handlePostSignIn({
    User? user,
    String? email,
    bool isSignup = false,
    String? userName,
  }) async {
    final userEmail = user?.email ?? email ?? '';
    final uid = user?.uid ?? '';

    if (isSignup && userName != null && uid.isNotEmpty) {
      final names = userName.trim().split(' ');
      await setUserProfile(
        uid: uid,
        firstName: names.isNotEmpty ? names.first : '',
        lastName: names.length > 1 ? names.last : '',
        email: userEmail,
      );
    }

    final profile = await getUserProfile(uid);
    final storedName = profile?['firstName'] ?? user?.displayName ?? '';

    await _storage.setUserLoggedIn(
      email: userEmail,
      name: storedName,
      userId: uid,
    );
  }

  // Sign up with Email and Password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with Email and Password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Create/Update User Profile
  Future<void> setUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    if (uid.isEmpty) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.clearUserData();
  }
}
