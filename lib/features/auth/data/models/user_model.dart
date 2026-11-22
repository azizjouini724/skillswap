import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillswap/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.photoUrl,
  });

  factory UserModel.fromFirebaseAuth(User user) {
    return UserModel(
      uid: user.uid,
      name: user.displayName ?? user.email?.split('@').first ?? 'Utilisateur',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }

  /// Document créé dans users/{uid} à l'inscription.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'bio': '',
      'photoUrl': photoUrl ?? '',
      'skillsToTeach': <String>[],
      'skillsToLearn': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}