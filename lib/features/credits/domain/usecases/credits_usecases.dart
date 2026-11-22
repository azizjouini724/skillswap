import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/credits/domain/entities/completed_session_ref.dart';
import 'package:skillswap/features/credits/domain/entities/credit_transaction.dart';
import 'package:skillswap/features/credits/domain/repositories/credits_repository.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

class WatchTransactionsUseCase {
  final CreditsRepository repository;
  WatchTransactionsUseCase(this.repository);

  Stream<List<CreditTransaction>> call(String uid) =>
      repository.watchTransactions(uid);
}

class WatchCompletedSessionsUseCase {
  final CreditsRepository repository;
  WatchCompletedSessionsUseCase(this.repository);

  Stream<List<CompletedSessionRef>> call(String uid) =>
      repository.watchCompletedSessions(uid);
}

class ClaimProfileBonusUseCase {
  final CreditsRepository repository;
  ClaimProfileBonusUseCase(this.repository);

  Future<Either<Failure, Unit>> call(ProfileEntity profile) async {
    final complete = profile.hasBio &&
        profile.hasEnoughToTeach &&
        profile.hasEnoughToLearn;
    if (!complete) {
      return const Left(ValidationFailure('Complete your profile first'));
    }
    return repository.claimBonus(profile.uid);
  }
}

class ClaimSessionCreditsUseCase {
  final CreditsRepository repository;
  ClaimSessionCreditsUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String uid,
    required CompletedSessionRef session,
  }) {
    return repository.claimSession(uid: uid, session: session);
  }
}