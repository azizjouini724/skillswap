import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/credits/domain/entities/completed_session_ref.dart';
import 'package:skillswap/features/credits/domain/entities/credit_ledger.dart';
import 'package:skillswap/features/credits/domain/entities/credit_transaction.dart';
import 'package:skillswap/features/credits/domain/repositories/credits_repository.dart';
import 'package:skillswap/features/credits/domain/usecases/credits_usecases.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

class FakeCreditsRepository implements CreditsRepository {
  final List<String> bonusClaims = [];

  @override
  Stream<List<CreditTransaction>> watchTransactions(String uid) =>
      const Stream.empty();

  @override
  Stream<List<CompletedSessionRef>> watchCompletedSessions(String uid) =>
      const Stream.empty();

  @override
  Future<Either<Failure, Unit>> claimBonus(String uid) async {
    bonusClaims.add(uid);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> claimSession({
    required String uid,
    required CompletedSessionRef session,
  }) async =>
      const Right(unit);
}

CreditTransaction tx(String id, String kind, int delta) => CreditTransaction(
      id: id,
      kind: kind,
      delta: delta,
      label: '',
      createdAt: DateTime(2026, 11, 22),
    );

void main() {
  const session = CompletedSessionRef(id: 's1', exchangeId: 'e1');

  group('CreditLedger', () {
    test('le solde est la somme des mouvements', () {
      final list = [
        tx('bonus_u', CreditKind.bonus, 50),
        tx('teach_s1_u', CreditKind.teach, 1),
        tx('learn_s1_u', CreditKind.learn, -1),
      ];
      expect(CreditLedger.balance(list), 50);
    });

    test('le bonus est détecté', () {
      expect(CreditLedger.hasBonus([tx('bonus_u', CreditKind.bonus, 50)]), true);
      expect(CreditLedger.hasBonus([]), false);
    });

    test('les identifiants sont déterministes', () {
      expect(CreditLedger.bonusId('u'), 'bonus_u');
      expect(CreditLedger.teachId('s1', 'u'), 'teach_s1_u');
      expect(CreditLedger.learnId('s1', 'u'), 'learn_s1_u');
    });

    test('une séance sans mouvement est à créditer', () {
      final missing = CreditLedger.unclaimed(
        uid: 'u',
        sessions: [session],
        transactions: [],
      );
      expect(missing, [session]);
    });

    test('une séance déjà créditée ne l\'est pas deux fois', () {
      final missing = CreditLedger.unclaimed(
        uid: 'u',
        sessions: [session],
        transactions: [
          tx('teach_s1_u', CreditKind.teach, 1),
          tx('learn_s1_u', CreditKind.learn, -1),
        ],
      );
      expect(missing, isEmpty);
    });

    test('les mouvements d\'un autre utilisateur ne comptent pas', () {
      final missing = CreditLedger.unclaimed(
        uid: 'u',
        sessions: [session],
        transactions: [
          tx('teach_s1_other', CreditKind.teach, 1),
          tx('learn_s1_other', CreditKind.learn, -1),
        ],
      );
      expect(missing, [session]);
    });
  });

  group('ClaimProfileBonusUseCase', () {
    test('refuse un profil incomplet', () async {
      final repo = FakeCreditsRepository();
      final result = await ClaimProfileBonusUseCase(repo)(
        const ProfileEntity(uid: 'u', name: 'Ahmed', email: 'a@a.com'),
      );

      expect(result.isLeft(), true);
      expect(repo.bonusClaims, isEmpty);
    });

    test('accepte un profil complet', () async {
      final repo = FakeCreditsRepository();
      final result = await ClaimProfileBonusUseCase(repo)(
        const ProfileEntity(
          uid: 'u',
          name: 'Ahmed',
          email: 'a@a.com',
          bio: 'Flutter student',
          skillsToTeach: ['Flutter', 'Dart'],
          skillsToLearn: ['Photoshop', 'UI/UX Design'],
        ),
      );

      expect(result.isRight(), true);
      expect(repo.bonusClaims, ['u']);
    });
  });
}