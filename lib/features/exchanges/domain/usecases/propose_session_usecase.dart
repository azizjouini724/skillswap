import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_status.dart';
import 'package:skillswap/features/exchanges/domain/repositories/exchange_repository.dart';

class ProposeSessionUseCase {
  final ExchangeRepository repository;
  ProposeSessionUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required ExchangeEntity exchange,
    required String uid,
    required DateTime startAt,
    required int durationMinutes,
    required String meetingMode,
    DateTime? now,
  }) async {
    if (!exchange.involves(uid)) {
      return const Left(ValidationFailure('Action non autorisée'));
    }
    if (!exchange.isAccepted) {
      return const Left(ValidationFailure(
          "Tu peux planifier une séance seulement après l'acceptation"));
    }
    if (!startAt.isAfter(now ?? DateTime.now())) {
      return const Left(ValidationFailure('Choisis une date dans le futur'));
    }
    if (durationMinutes < 15 || durationMinutes > 240) {
      return const Left(ValidationFailure('Durée invalide (15 à 240 min)'));
    }
    if (meetingMode != MeetingMode.online &&
        meetingMode != MeetingMode.inPerson) {
      return const Left(ValidationFailure('Mode de séance invalide'));
    }

    return repository.proposeSession(
      exchangeId: exchange.id,
      hostId: uid,
      participantIds: exchange.participantIds,
      startAt: startAt,
      durationMinutes: durationMinutes,
      meetingMode: meetingMode,
    );
  }
}