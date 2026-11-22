import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_status.dart';
import 'package:skillswap/features/exchanges/domain/entities/session_entity.dart';
import 'package:skillswap/features/exchanges/domain/repositories/exchange_repository.dart';
import 'package:skillswap/features/exchanges/domain/usecases/counter_propose_session_usecase.dart';
import 'package:skillswap/features/exchanges/domain/usecases/propose_session_usecase.dart';
import 'package:skillswap/features/exchanges/domain/usecases/send_exchange_request_usecase.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

class FakeExchangeRepository implements ExchangeRepository {
  int sent = 0;
  int proposed = 0;
  int countered = 0;

  @override
  Stream<List<ExchangeEntity>> watchExchanges(String uid) =>
      const Stream.empty();

  @override
  Stream<List<SessionEntity>> watchSessions(String uid) =>
      const Stream.empty();

  @override
  Future<Either<Failure, Unit>> sendRequest({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String offeredSkill,
    required String requestedSkill,
    required String message,
  }) async {
    sent++;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> updateExchangeStatus({
    required String exchangeId,
    required String status,
  }) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> proposeSession({
    required String exchangeId,
    required String hostId,
    required List<String> participantIds,
    required DateTime startAt,
    required int durationMinutes,
    required String meetingMode,
  }) async {
    proposed++;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> updateSessionStatus({
    required String sessionId,
    required String status,
  }) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> counterProposeSession({
    required String sessionId,
    required String uid,
    required DateTime startAt,
    required int durationMinutes,
    required String meetingMode,
  }) async {
    countered++;
    return const Right(unit);
  }
}

ExchangeEntity exchange(String status) => ExchangeEntity(
      id: 'x1',
      senderId: 'ahmed',
      receiverId: 'sara',
      senderName: 'Ahmed',
      receiverName: 'Sara',
      offeredSkill: 'Flutter',
      requestedSkill: 'Photoshop',
      status: status,
      createdAt: DateTime(2026, 11, 22),
    );

SessionEntity session({
  String host = 'ahmed',
  String status = SessionStatus.proposed,
}) =>
    SessionEntity(
      id: 's1',
      exchangeId: 'x1',
      hostId: host,
      participantIds: const ['ahmed', 'sara'],
      startAt: DateTime(2026, 11, 25, 18),
      durationMinutes: 60,
      meetingMode: MeetingMode.online,
      status: status,
    );

void main() {
  group('transitions d\'un échange', () {
    test('le destinataire accepte ou refuse, pas l\'expéditeur', () {
      final e = exchange(ExchangeStatus.pending);
      expect(e.canChangeTo('sara', ExchangeStatus.accepted), true);
      expect(e.canChangeTo('sara', ExchangeStatus.rejected), true);
      expect(e.canChangeTo('ahmed', ExchangeStatus.accepted), false);
    });

    test('l\'expéditeur peut annuler une demande en attente', () {
      final e = exchange(ExchangeStatus.pending);
      expect(e.canChangeTo('ahmed', ExchangeStatus.cancelled), true);
      expect(e.canChangeTo('sara', ExchangeStatus.cancelled), false);
    });

    test('un échange refusé est définitif', () {
      final e = exchange(ExchangeStatus.rejected);
      expect(e.canChangeTo('sara', ExchangeStatus.accepted), false);
      expect(e.canChangeTo('ahmed', ExchangeStatus.cancelled), false);
    });

    test('un échange accepté peut être terminé par les deux', () {
      final e = exchange(ExchangeStatus.accepted);
      expect(e.canChangeTo('ahmed', ExchangeStatus.completed), true);
      expect(e.canChangeTo('sara', ExchangeStatus.completed), true);
    });

    test('un tiers ne peut rien faire', () {
      final e = exchange(ExchangeStatus.pending);
      expect(e.canChangeTo('youssef', ExchangeStatus.accepted), false);
    });
  });

  group('SendExchangeRequestUseCase', () {
    const ahmed = ProfileEntity(
      uid: 'ahmed',
      name: 'Ahmed',
      email: 'a@a.com',
      skillsToTeach: ['Flutter'],
      skillsToLearn: ['Photoshop'],
    );
    const sara = ProfileEntity(
      uid: 'sara',
      name: 'Sara',
      email: 's@s.com',
      skillsToTeach: ['Photoshop'],
      skillsToLearn: ['Flutter'],
    );

    late FakeExchangeRepository repo;
    late SendExchangeRequestUseCase useCase;

    setUp(() {
      repo = FakeExchangeRepository();
      useCase = SendExchangeRequestUseCase(repo);
    });

    test('envoie une demande valide', () async {
      final result = await useCase(
        me: ahmed,
        other: sara,
        offeredSkill: 'Flutter',
        requestedSkill: 'Photoshop',
        existing: const [],
      );
      expect(result.isRight(), true);
      expect(repo.sent, 1);
    });

    test('refuse un doublon en attente', () async {
      final result = await useCase(
        me: ahmed,
        other: sara,
        offeredSkill: 'Flutter',
        requestedSkill: 'Photoshop',
        existing: [exchange(ExchangeStatus.pending)],
      );
      expect(result.isLeft(), true);
      expect(repo.sent, 0);
    });

    test("refuse d'offrir une compétence qu'on n'enseigne pas", () async {
      final result = await useCase(
        me: ahmed,
        other: sara,
        offeredSkill: 'Guitar',
        requestedSkill: 'Photoshop',
        existing: const [],
      );
      expect(result.isLeft(), true);
      expect(repo.sent, 0);
    });
  });

  group('ProposeSessionUseCase', () {
    late FakeExchangeRepository repo;
    late ProposeSessionUseCase useCase;
    final now = DateTime(2026, 11, 22, 12);

    setUp(() {
      repo = FakeExchangeRepository();
      useCase = ProposeSessionUseCase(repo);
    });

    Future<Either<Failure, Unit>> propose(ExchangeEntity e, DateTime start,
        {int minutes = 60}) {
      return useCase(
        exchange: e,
        uid: 'ahmed',
        startAt: start,
        durationMinutes: minutes,
        meetingMode: MeetingMode.online,
        now: now,
      );
    }

    test('refuse tant que l\'échange n\'est pas accepté', () async {
      final result = await propose(
          exchange(ExchangeStatus.pending), now.add(const Duration(days: 1)));
      expect(result.isLeft(), true);
      expect(repo.proposed, 0);
    });

    test('refuse une date passée', () async {
      final result = await propose(exchange(ExchangeStatus.accepted),
          now.subtract(const Duration(hours: 1)));
      expect(result.isLeft(), true);
    });

    test('refuse une durée hors limites', () async {
      final result = await propose(
          exchange(ExchangeStatus.accepted), now.add(const Duration(days: 1)),
          minutes: 500);
      expect(result.isLeft(), true);
    });

    test('accepte une séance valide sur un échange accepté', () async {
      final result = await propose(
          exchange(ExchangeStatus.accepted), now.add(const Duration(days: 1)));
      expect(result.isRight(), true);
      expect(repo.proposed, 1);
    });
  });

  group('CounterProposeSessionUseCase', () {
    late FakeExchangeRepository repo;
    late CounterProposeSessionUseCase useCase;
    final now = DateTime(2026, 11, 22, 12);
    final later = now.add(const Duration(days: 2));

    setUp(() {
      repo = FakeExchangeRepository();
      useCase = CounterProposeSessionUseCase(repo);
    });

    Future<Either<Failure, Unit>> counter(SessionEntity s, String uid) {
      return useCase(
        session: s,
        uid: uid,
        startAt: later,
        durationMinutes: 60,
        meetingMode: MeetingMode.online,
        now: now,
      );
    }

    test("l'autre personne peut proposer une nouvelle date", () async {
      final result = await counter(session(host: 'ahmed'), 'sara');
      expect(result.isRight(), true);
      expect(repo.countered, 1);
    });

    test('on ne peut pas contre-proposer sa propre proposition', () async {
      final result = await counter(session(host: 'ahmed'), 'ahmed');
      expect(result.isLeft(), true);
      expect(repo.countered, 0);
    });

    test('impossible une fois la séance confirmée', () async {
      final result = await counter(
          session(host: 'ahmed', status: SessionStatus.confirmed), 'sara');
      expect(result.isLeft(), true);
      expect(repo.countered, 0);
    });
  });
}