import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/exchanges/data/datasources/exchange_remote_datasource.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/domain/entities/session_entity.dart';
import 'package:skillswap/features/exchanges/domain/repositories/exchange_repository.dart';

class ExchangeRepositoryImpl implements ExchangeRepository {
  final ExchangeRemoteDataSource remote;
  ExchangeRepositoryImpl(this.remote);

  @override
  Stream<List<ExchangeEntity>> watchExchanges(String uid) =>
      remote.watchExchanges(uid);

  @override
  Stream<List<SessionEntity>> watchSessions(String uid) =>
      remote.watchSessions(uid);

  @override
  Future<Either<Failure, Unit>> sendRequest({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String offeredSkill,
    required String requestedSkill,
    required String message,
  }) {
    return _guard(() => remote.sendRequest(
          senderId: senderId,
          senderName: senderName,
          receiverId: receiverId,
          receiverName: receiverName,
          offeredSkill: offeredSkill,
          requestedSkill: requestedSkill,
          message: message,
        ));
  }

  @override
  Future<Either<Failure, Unit>> updateExchangeStatus({
    required String exchangeId,
    required String status,
  }) {
    return _guard(() => remote.updateExchangeStatus(exchangeId, status));
  }

  @override
  Future<Either<Failure, Unit>> proposeSession({
    required String exchangeId,
    required String hostId,
    required List<String> participantIds,
    required DateTime startAt,
    required int durationMinutes,
    required String meetingMode,
  }) {
    return _guard(() => remote.proposeSession(
          exchangeId: exchangeId,
          hostId: hostId,
          participantIds: participantIds,
          startAt: startAt,
          durationMinutes: durationMinutes,
          meetingMode: meetingMode,
        ));
  }

  @override
  Future<Either<Failure, Unit>> updateSessionStatus({
    required String sessionId,
    required String status,
  }) {
    return _guard(() => remote.updateSessionStatus(sessionId, status));
  }
    @override
  Future<Either<Failure, Unit>> counterProposeSession({
    required String sessionId,
    required String uid,
    required DateTime startAt,
    required int durationMinutes,
    required String meetingMode,
  }) {
    return _guard(() => remote.counterProposeSession(
          sessionId: sessionId,
          uid: uid,
          startAt: startAt,
          durationMinutes: durationMinutes,
          meetingMode: meetingMode,
        ));
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