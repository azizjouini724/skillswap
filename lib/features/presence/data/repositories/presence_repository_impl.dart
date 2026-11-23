import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/presence/data/datasources/presence_remote_datasource.dart';
import 'package:skillswap/features/presence/domain/repositories/presence_repository.dart';

class PresenceRepositoryImpl implements PresenceRepository {
  final PresenceRemoteDataSource remote;
  PresenceRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Unit>> touch(String uid) async {
    try {
      await remote.touch(uid);
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erreur serveur'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}