import 'package:skillswap/features/matching/domain/entities/match_entity.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/skills/domain/entities/skill_catalog.dart';

class MatchFinder {
  /// Pour chaque autre utilisateur B :
  ///   mutual_1 = A_to_learn ∩ B_to_teach
  ///   mutual_2 = B_to_learn ∩ A_to_teach
  ///   B est un match seulement si mutual_1 ET mutual_2 sont non vides.
  static List<MatchEntity> find(ProfileEntity me, List<ProfileEntity> others) {
    final matches = <MatchEntity>[];

    for (final other in others) {
      if (other.uid == me.uid) continue;

      final youLearn = _intersection(me.skillsToLearn, other.skillsToTeach);
      final youTeach = _intersection(me.skillsToTeach, other.skillsToLearn);

      if (youLearn.isNotEmpty && youTeach.isNotEmpty) {
        matches.add(MatchEntity(
          profile: other,
          youLearn: youLearn,
          youTeach: youTeach,
        ));
      }
    }

    matches.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.profile.name.toLowerCase().compareTo(b.profile.name.toLowerCase());
    });
    return matches;
  }

  /// Compétences de [wanted] que l'on retrouve dans [offered]
  /// (comparaison insensible à la casse et aux espaces).
  static List<String> _intersection(List<String> wanted, List<String> offered) {
    final offeredKeys = offered.map(SkillCatalog.normalize).toSet();
    return wanted
        .where((s) => offeredKeys.contains(SkillCatalog.normalize(s)))
        .toList();
  }
}