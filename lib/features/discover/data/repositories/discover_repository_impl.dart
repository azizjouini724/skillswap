import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/discover/data/datasources/discover_remote_datasource.dart';
import 'package:skillswap/features/discover/domain/repositories/discover_repository.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

class DiscoverRepositoryImpl implements DiscoverRepository {
  final DiscoverRemoteDataSource remote;
  DiscoverRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<ProfileEntity>>> fetchProfiles({
    required int limit,
  }) async {
    try {
      final profiles = await remote.fetchProfiles(limit: limit);
      return Right(profiles);
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