import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/app_user.dart';

/// Reads the Firestore user profile for the authenticated Firebase UID.
///
/// IMPORTANT: This repository intentionally does NOT expose a method to
/// set `role` or `active` from the client. Those fields must only ever
/// be written by trusted backend logic (Cloud Functions / admin panel),
/// matching Step 6/Step 9 of the Phase 1 brief and the Firestore rules
/// in firebase/firestore.rules.
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Returns null if no profile document exists yet — the caller must
  /// treat this as "account not found", never as "create one on the fly"
  /// (account provisioning for staff/salesman/admin is an admin-side
  /// operation, not something a client login attempt should trigger).
  Future<AppUser?> getUser(String uid) async {
    final snapshot = await _userDoc(uid).get();
    if (!snapshot.exists) return null;
    return AppUser.fromFirestore(snapshot);
  }

  Stream<AppUser?> watchUser(String uid) {
    return _userDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return AppUser.fromFirestore(snapshot);
    });
  }

  /// Updates only `lastLoginAt`. This is the one field a client is
  /// permitted to write to its own profile — enforced in firestore.rules.
  Future<void> markLoginTimestamp(String uid) async {
    await _userDoc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }
}
