import 'package:flutter_test/flutter_test.dart' hide MatchFinder;
import 'package:skillswap/features/matching/domain/usecases/match_finder.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
void main() {
  const ahmed = ProfileEntity(
    uid: 'ahmed',
    name: 'Ahmed',
    email: 'a@a.com',
    skillsToTeach: ['Flutter', 'Dart'],
    skillsToLearn: ['Photoshop', 'UI/UX Design'],
  );

  // Réciproque : enseigne Photoshop, veut apprendre Flutter.
  const sara = ProfileEntity(
    uid: 'sara',
    name: 'Sara',
    email: 's@s.com',
    skillsToTeach: ['Photoshop'],
    skillsToLearn: ['Flutter'],
  );

  // Aucun recoupement.
  const youssef = ProfileEntity(
    uid: 'youssef',
    name: 'Youssef',
    email: 'y@y.com',
    skillsToTeach: ['Python'],
    skillsToLearn: ['English'],
  );

  // À sens unique : enseigne Photoshop, mais ne veut rien de ce qu'Ahmed enseigne.
  const karim = ProfileEntity(
    uid: 'karim',
    name: 'Karim',
    email: 'k@k.com',
    skillsToTeach: ['Photoshop'],
    skillsToLearn: ['Guitar'],
  );

  // Réciproque avec une casse différente, et plus de compétences communes.
  const nadia = ProfileEntity(
    uid: 'nadia',
    name: 'Nadia',
    email: 'n@n.com',
    skillsToTeach: ['photoshop', 'ui/ux design'],
    skillsToLearn: ['flutter', 'DART'],
  );

  test('détecte un match réciproque et explique les deux compétences', () {
    final matches = MatchFinder.find(ahmed, [sara]);

    expect(matches, hasLength(1));
    expect(matches.first.profile.uid, 'sara');
    expect(matches.first.youLearn, ['Photoshop']);
    expect(matches.first.youTeach, ['Flutter']);
  });

  test('ne propose pas un profil sans recoupement', () {
    expect(MatchFinder.find(ahmed, [youssef]), isEmpty);
  });

  test('ne propose pas un match à sens unique', () {
    expect(MatchFinder.find(ahmed, [karim]), isEmpty);
  });

  test('ignore la casse et trie par nombre de compétences communes', () {
    final matches = MatchFinder.find(ahmed, [sara, youssef, karim, nadia]);

    expect(matches.map((m) => m.profile.uid), ['nadia', 'sara']);
    expect(matches.first.score, 4);
  });

  test("ne se propose pas lui-même", () {
    expect(MatchFinder.find(ahmed, [ahmed]), isEmpty);
  });
}