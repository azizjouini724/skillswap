import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/credits/domain/entities/completed_session_ref.dart';
import 'package:skillswap/features/credits/domain/entities/credit_transaction.dart';

abstract class CreditsRepository {
  Stream<List<CreditTransaction>> watchTransactions(String uid);
  Stream<List<CompletedSessionRef>> watchCompletedSessions(String uid);
  Future<Either<Failure, Unit>> claimBonus(String uid);
  Future<Either<Failure, Unit>> claimSession({
    required String uid,
    required CompletedSessionRef session,
  });
}