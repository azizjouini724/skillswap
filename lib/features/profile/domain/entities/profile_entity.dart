import 'package:equatable/equatable.dart';
import 'package:skillswap/features/skills/domain/entities/skill_type.dart';

class ProfileEntity extends Equatable {
  static const totalSteps = 3;

  final String uid;
  final String name;
  final String email;
  final String bio;
  final String city;
  final String? photoUrl;
  final List<String> skillsToTeach;
  final List<String> skillsToLearn;
  final DateTime? lastSeen;
  const ProfileEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.bio = '',
    this.city = '',
    this.photoUrl,
    this.skillsToTeach = const [],
    this.skillsToLearn = const [],
    this.lastSeen,
  });

  List<String> skillsOf(SkillType type) =>
      type == SkillType.teach ? skillsToTeach : skillsToLearn;

  bool get hasBio => bio.trim().isNotEmpty;
  static const onlineWindow = Duration(minutes: 5);

  bool isOnlineAt(DateTime now) =>
      lastSeen != null && now.difference(lastSeen!) < onlineWindow;

  bool get isOnline => isOnlineAt(DateTime.now());
  bool get hasEnoughToTeach => skillsToTeach.length >= 2;
  bool get hasEnoughToLearn => skillsToLearn.length >= 2;

  int get completedSteps =>
      [hasBio, hasEnoughToTeach, hasEnoughToLearn].where((d) => d).length;

  double get completion => completedSteps / totalSteps;

  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
    List<Object?> get props =>
      [uid, name, email, bio, city, photoUrl, skillsToTeach, skillsToLearn, lastSeen];
}