import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/features/profile/data/models/profile_model.dart';
import 'package:skillswap/features/skills/domain/entities/skill_type.dart';

abstract class ProfileRemoteDataSource {
  Stream<ProfileModel?> watchProfile(String uid);
  Future<void> updateProfile(
    String uid, {
    required String name,
    required String bio,
    required String city,
  });
  Future<void> addSkill(String uid, SkillType type, String skill);
  Future<void> removeSkill(String uid, SkillType type, String skill);
    Future<void> updatePhoto(String uid, String? photo);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  ProfileRemoteDataSourceImpl(this.firestore);

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      firestore.collection('users').doc(uid);

  String _field(SkillType type) =>
      type == SkillType.teach ? 'skillsToTeach' : 'skillsToLearn';

  @override
  Stream<ProfileModel?> watchProfile(String uid) {
    return _doc(uid).snapshots().map((snap) {
      final data = snap.data();
      return data == null ? null : ProfileModel.fromMap(data, snap.id);
    });
  }

  @override
  Future<void> updateProfile(
    String uid, {
    required String name,
    required String bio,
    required String city,
  }) {
    return _doc(uid).update({
      'name': name,
      'bio': bio,
      'city': city,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> addSkill(String uid, SkillType type, String skill) {
    return _doc(uid).update({
      _field(type): FieldValue.arrayUnion([skill]),
    });
  }

  @override
  Future<void> removeSkill(String uid, SkillType type, String skill) {
    return _doc(uid).update({
      _field(type): FieldValue.arrayRemove([skill]),
    });
  }
    @override
  Future<void> updatePhoto(String uid, String? photo) {
    return _doc(uid).update({
      'photoUrl': photo ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}