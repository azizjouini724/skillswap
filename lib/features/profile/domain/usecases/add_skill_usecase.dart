import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/profile/domain/repositories/profile_repository.dart';
import 'package:skillswap/features/skills/domain/entities/skill_catalog.dart';
import 'package:skillswap/features/skills/domain/entities/skill_type.dart';

class AddSkillUseCase {
  final ProfileRepository repository;
  AddSkillUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required ProfileEntity profile,
    required SkillType type,
    required String skill,
  }) async {
    final name = SkillCatalog.displayName(skill);
    if (name.isEmpty) {
      return const Left(ValidationFailure('Saisis une compétence'));
    }
    if (name.length > 40) {
      return const Left(ValidationFailure('Compétence trop longue (40 max)'));
    }

    final key = SkillCatalog.normalize(name);
    bool has(List<String> list) =>
        list.any((s) => SkillCatalog.normalize(s) == key);

    final isTeach = type == SkillType.teach;
    if (has(profile.skillsOf(type))) {
      return const Left(
          ValidationFailure('Cette compétence est déjà dans ta liste'));
    }
    if (has(profile.skillsOf(isTeach ? SkillType.learn : SkillType.teach))) {
      return Left(ValidationFailure(isTeach
          ? 'Tu as déjà cette compétence dans « à apprendre »'
          : 'Tu as déjà cette compétence dans « à enseigner »'));
    }

    return repository.addSkill(uid: profile.uid, type: type, skill: name);
  }
}