import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/skills/domain/entities/skill_type.dart';

abstract class ProfileRepository {
  Stream<ProfileEntity?> watchProfile(String uid);

  Future<Either<Failure, Unit>> updateProfile({
    required String uid,
    required String name,
    required String bio,
    required String city,
  });

  Future<Either<Failure, Unit>> addSkill({
    required String uid,
    required SkillType type,
    required String skill,
  });

  Future<Either<Failure, Unit>> removeSkill({
    required String uid,
    required SkillType type,
    required String skill,
  });
    Future<Either<Failure, Unit>> updatePhoto({
    required String uid,
    required String? photo,
  });
}