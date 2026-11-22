import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/skills/domain/entities/skill_catalog.dart';

class ProfileFilter {
  /// Garde les profils dont une compétence ENSEIGNÉE ou le nom correspond
  /// à la recherche, et dont une compétence enseignée est dans la catégorie.
  static List<ProfileEntity> apply(
    List<ProfileEntity> profiles, {
    String query = '',
    String? categoryId,
  }) {
    final q = SkillCatalog.normalize(query);

    return profiles.where((p) {
      if (categoryId != null &&
          !p.skillsToTeach
              .any((s) => SkillCatalog.categoryOf(s) == categoryId)) {
        return false;
      }
      if (q.isEmpty) return true;

      final inName = SkillCatalog.normalize(p.name).contains(q);
      final inSkills =
          p.skillsToTeach.any((s) => SkillCatalog.normalize(s).contains(q));
      return inName || inSkills;
    }).toList();
  }
}