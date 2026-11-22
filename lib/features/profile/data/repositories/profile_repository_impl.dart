import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/profile/domain/repositories/profile_repository.dart';
import 'package:skillswap/features/skills/domain/entities/skill_type.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  ProfileRepositoryImpl(this.remote);

  @override
  Stream<ProfileEntity?> watchProfile(String uid) => remote.watchProfile(uid);

  @override
  Future<Either<Failure, Unit>> updateProfile({
    required String uid,
    required String name,
    required String bio,
    required String city,
  }) {
    return _guard(
        () => remote.updateProfile(uid, name: name, bio: bio, city: city));
  }

  @override
  Future<Either<Failure, Unit>> addSkill({
    required String uid,
    required SkillType type,
    required String skill,
  }) {
    return _guard(() => remote.addSkill(uid, type, skill));
  }

  @override
  Future<Either<Failure, Unit>> removeSkill({
    required String uid,
    required SkillType type,
    required String skill,
  }) {
    return _guard(() => remote.removeSkill(uid, type, skill));
  }
    @override
  Future<Either<Failure, Unit>> updatePhoto({
    required String uid,
    required String? photo,
  }) {
    return _guard(() => remote.updatePhoto(uid, photo));
  }

  Future<Either<Failure, Unit>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return const Left(ServerFailure('Action non autorisée'));
      }
      if (e.code == 'unavailable') return const Left(NetworkFailure());
      return Left(ServerFailure(e.message ?? 'Erreur serveur'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}