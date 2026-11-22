import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/profile/domain/repositories/profile_repository.dart';
import 'package:skillswap/features/profile/domain/usecases/add_skill_usecase.dart';
import 'package:skillswap/features/skills/domain/entities/skill_type.dart';

class FakeProfileRepository implements ProfileRepository {
  final List<String> added = [];

  @override
  Stream<ProfileEntity?> watchProfile(String uid) => const Stream.empty();

  @override
  Future<Either<Failure, Unit>> updateProfile({
    required String uid,
    required String name,
    required String bio,
    required String city,
  }) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> addSkill({
    required String uid,
    required SkillType type,
    required String skill,
  }) async {
    added.add(skill);
    return const Right(unit);
  }
@override
  Future<Either<Failure, Unit>> updatePhoto({
    required String uid,
    required String? photo,
  }) async =>
      const Right(unit);
  @override
  Future<Either<Failure, Unit>> removeSkill({
    required String uid,
    required SkillType type,
    required String skill,
  }) async =>
      const Right(unit);
}


void main() {
  const profile = ProfileEntity(
    uid: '1',
    name: 'Ahmed',
    email: 'a@a.com',
    skillsToTeach: ['Flutter'],
    skillsToLearn: ['Photoshop'],
  );

  late FakeProfileRepository repo;
  late AddSkillUseCase useCase;

  setUp(() {
    repo = FakeProfileRepository();
    useCase = AddSkillUseCase(repo);
  });

  test('ajoute une nouvelle compétence avec son nom canonique', () async {
    final result = await useCase(
        profile: profile, type: SkillType.teach, skill: '  dart ');
    expect(result.isRight(), true);
    expect(repo.added, ['Dart']);
  });

  test('refuse un doublon, sans tenir compte de la casse', () async {
    final result = await useCase(
        profile: profile, type: SkillType.teach, skill: 'flutter');
    expect(result.isLeft(), true);
    expect(repo.added, isEmpty);
  });

  test('refuse une compétence déjà présente dans l\'autre liste', () async {
    final result = await useCase(
        profile: profile, type: SkillType.learn, skill: 'Flutter');
    expect(result.isLeft(), true);
    expect(repo.added, isEmpty);
  });
}