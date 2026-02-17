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
    String? phoneNumber,
    bool isSignup = false,
    String? userName,
  }) async {
    final phone = user?.phoneNumber ?? phoneNumber ?? '';
    final uid = user?.uid ?? phone;

    if (isSignup && userName != null) {
      final names = userName.trim().split(' ');
      await setUserProfile(
        uid: uid,
        firstName: names.isNotEmpty ? names.first : '',
        lastName: names.length > 1 ? names.last : '',
        phoneNumber: phone,
      );
    }

    final profile = await getUserProfile(uid);
    final storedName = profile?['firstName'] ?? user?.displayName ?? '';

    await _storage.setUserLoggedIn(
      phone: phone,
      name: storedName,
      userId: 'user_$phone',
    );
  }

  // Send OTP
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onAutoVerification,
    required Function(String) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onAutoVerification, // Android only
      verificationFailed: onVerificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        onCodeSent(verificationId);
      },
      timeout: const Duration(seconds: 60),
    );
  }

  // Confirm OTP and return UserCredential
  Future<UserCredential> confirmOtp(
      String verificationId, String smsCode) async {
    final cred = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    return _auth.signInWithCredential(cred);
  }

  // Sign in with Credential (for auto-verification)
  Future<UserCredential> signInWithCredential(
      PhoneAuthCredential credential) async {
    return _auth.signInWithCredential(credential);
  }

  // Create/Update User Profile
  Future<void> setUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    await _db.collection('users').doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }
}
