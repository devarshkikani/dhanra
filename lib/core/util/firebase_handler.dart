import 'package:firebase_auth/firebase_auth.dart';

class FirebaseHandler {
  /// Maps Firebase exceptions to user-friendly messages.
  static String getReadableErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-phone-number':
          return 'The phone number you entered is invalid. Please check and try again.';
        case 'user-disabled':
          return 'This user account has been disabled. Please contact support.';
        case 'user-not-found':
          return 'No account found for this phone number. Please sign up.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-verification-code':
          return 'The OTP you entered is incorrect. Please check and try again.';
        case 'invalid-verification-id':
          return 'Invalid verification session. Please request a new OTP.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'operation-not-allowed':
          return 'This authentication method is not enabled. Please contact support.';
        case 'credential-already-in-use':
          return 'This phone number is already linked to another account.';
        case 'quota-exceeded':
          return 'SMS quota exceeded. Please try again later.';
        case 'session-expired':
          return 'The verification session has expired. Please request a new OTP.';
        case 'channel-error':
          return 'An internal error occurred. Please try again later.';
        default:
          return 'An unexpected authentication error occurred: ${error.message ?? error.code}';
      }
    } else if (error is FirebaseException) {
      return 'A database error occurred: ${error.message ?? error.code}';
    }

    // Default error message for non-Firebase errors
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Error: ', '');
  }
}
