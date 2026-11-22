import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_status.dart';
import 'package:skillswap/features/exchanges/domain/entities/session_entity.dart';
import 'package:skillswap/features/exchanges/domain/repositories/exchange_repository.dart';

class CounterProposeSessionUseCase {
  final ExchangeRepository repository;
  CounterProposeSessionUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required SessionEntity session,
    required String uid,
    required DateTime startAt,
    required int durationMinutes,
    required String meetingMode,
    DateTime? now,
  }) async {
    if (!session.canCounterPropose(uid)) {
      return const Left(ValidationFailure('Action non autorisée'));
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

    return repository.counterProposeSession(
      sessionId: session.id,
      uid: uid,
      startAt: startAt,
      durationMinutes: durationMinutes,
      meetingMode: meetingMode,
    );
  }
}