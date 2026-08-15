import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors a document at users/{firebaseUid}.
/// Fields match Phase 1 brief exactly — no extra fields invented.
class AppUser {
  final String uid;
  final String name;
  final String phone;
  final String role;
  final bool active;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    required this.active,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('AppUser.fromFirestore called on an empty document: ${doc.id}');
    }
    return AppUser(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? '',
      active: data['active'] as bool? ?? false,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }
}
