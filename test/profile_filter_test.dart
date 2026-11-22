import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/features/discover/domain/usecases/profile_filter.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

void main() {
  const sara = ProfileEntity(
    uid: '1',
    name: 'Sara',
    email: 's@s.com',
    skillsToTeach: ['Photoshop', 'UI/UX Design'],
    skillsToLearn: ['Flutter'],
  );
  const youssef = ProfileEntity(
    uid: '2',
    name: 'Youssef',
    email: 'y@y.com',
    skillsToTeach: ['Python'],
    skillsToLearn: ['English'],
  );
  const all = [sara, youssef];

  test('sans filtre, tout le monde est visible', () {
    expect(ProfileFilter.apply(all), all);
  });

  test('recherche par compétence enseignée', () {
    expect(ProfileFilter.apply(all, query: 'photo'), [sara]);
  });

  test('recherche par nom', () {
    expect(ProfileFilter.apply(all, query: 'yous'), [youssef]);
  });

  test('filtre par catégorie', () {
    expect(ProfileFilter.apply(all, categoryId: 'design'), [sara]);
    expect(ProfileFilter.apply(all, categoryId: 'tech'), [youssef]);
  });

  test('une compétence à apprendre ne compte pas dans la recherche', () {
    expect(ProfileFilter.apply(all, query: 'flutter'), isEmpty);
  });
}