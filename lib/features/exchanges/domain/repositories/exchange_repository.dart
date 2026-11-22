import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/domain/entities/session_entity.dart';

abstract class ExchangeRepository {
  Stream<List<ExchangeEntity>> watchExchanges(String uid);
  Stream<List<SessionEntity>> watchSessions(String uid);

  Future<Either<Failure, Unit>> sendRequest({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String offeredSkill,
    required String requestedSkill,
    required String message,
  });

  Future<Either<Failure, Unit>> updateExchangeStatus({
    required String exchangeId,
    required String status,
  });

  Future<Either<Failure, Unit>> proposeSession({
    required String exchangeId,
    required String hostId,
    required List<String> participantIds,
    required DateTime startAt,
    required int durationMinutes,
    required String meetingMode,
  });

  Future<Either<Failure, Unit>> updateSessionStatus({
    required String sessionId,
    required String status,
  });
    Future<Either<Failure, Unit>> counterProposeSession({
    required String sessionId,
    required String uid,
    required DateTime startAt,
    required int durationMinutes,
    required String meetingMode,
  });
}