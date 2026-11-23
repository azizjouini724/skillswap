import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.uid,
    required super.name,
    required super.email,
    super.bio,
    super.city,
    super.photoUrl,
    super.skillsToTeach,
    super.skillsToLearn,
    super.lastSeen,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map, String uid) {
    final photo = map['photoUrl'] as String?;
    final seen = map['lastSeen'];
    return ProfileModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      city: map['city'] ?? '',
      photoUrl: (photo == null || photo.isEmpty) ? null : photo,
      skillsToTeach: List<String>.from(map['skillsToTeach'] ?? const []),
      skillsToLearn: List<String>.from(map['skillsToLearn'] ?? const []),
      lastSeen: seen is Timestamp ? seen.toDate() : null,
    );
  }
}