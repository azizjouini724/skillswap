import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/profile/domain/repositories/profile_repository.dart';
import 'package:skillswap/features/skills/domain/entities/skill_type.dart';

class RemoveSkillUseCase {
  final ProfileRepository repository;
  RemoveSkillUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String uid,
    required SkillType type,
    required String skill,
  }) {
    return repository.removeSkill(uid: uid, type: type, skill: skill);
  }
}