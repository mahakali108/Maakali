import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/error_mapper.dart';

/// Thin wrapper around FirebaseAuth's phone OTP flow.
/// This is the ONLY authentication method in the app — no email/password,
/// no Google, no Facebook, no Apple, no magic link.
class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sends the OTP to [e164Phone] (e.g. "+919876543210").
  ///
  /// [onCodeSent] fires once the SMS has been dispatched, with the
  /// verificationId needed for [verifyOtp].
  /// [onAutoVerified] fires on Android auto-retrieval, skipping manual entry.
  /// [onFailed] fires on any FirebaseAuthException (invalid number,
  /// too-many-requests, quota-exceeded, network error, etc.) — mapped to
  /// a safe user-facing message before being handed back.
  Future<void> sendOtp({
    required String e164Phone,
    required void Function(String verificationId) onCodeSent,
    required void Function(UserCredential credential) onAutoVerified,
    required void Function(Exception mappedError) onFailed,
    int? resendToken,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: e164Phone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final result = await _auth.signInWithCredential(credential);
            onAutoVerified(result);
          } on FirebaseAuthException catch (e) {
            onFailed(AppErrorMapper.mapFirebaseAuthError(e));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onFailed(AppErrorMapper.mapFirebaseAuthError(e));
        },
        codeSent: (String verificationId, int? forceResendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // No-op: user can still enter the OTP manually.
        },
      );
    } on FirebaseAuthException catch (e) {
      onFailed(AppErrorMapper.mapFirebaseAuthError(e));
    }
  }

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AppErrorMapper.mapFirebaseAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
