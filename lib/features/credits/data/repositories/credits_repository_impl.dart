import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/credits/data/datasources/credits_remote_datasource.dart';
import 'package:skillswap/features/credits/domain/entities/completed_session_ref.dart';
import 'package:skillswap/features/credits/domain/entities/credit_transaction.dart';
import 'package:skillswap/features/credits/domain/repositories/credits_repository.dart';

class CreditsRepositoryImpl implements CreditsRepository {
  final CreditsRemoteDataSource remote;
  CreditsRepositoryImpl(this.remote);

  @override
  Stream<List<CreditTransaction>> watchTransactions(String uid) =>
      remote.watchTransactions(uid);

  @override
  Stream<List<CompletedSessionRef>> watchCompletedSessions(String uid) =>
      remote.watchCompletedSessions(uid);

  @override
  Future<Either<Failure, Unit>> claimBonus(String uid) =>
      _guard(() => remote.claimBonus(uid));

  @override
  Future<Either<Failure, Unit>> claimSession({
    required String uid,
    required CompletedSessionRef session,
  }) =>
      _guard(() => remote.claimSession(uid, session));

  Future<Either<Failure, Unit>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return const Left(
            ServerFailure('Credits already claimed or not allowed'));
      }
      if (e.code == 'unavailable') return const Left(NetworkFailure());
      return Left(ServerFailure(e.message ?? 'Erreur serveur'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}