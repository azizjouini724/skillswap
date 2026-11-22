import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/exchanges/domain/entities/session_entity.dart';
import 'package:skillswap/features/exchanges/domain/repositories/exchange_repository.dart';

class UpdateSessionStatusUseCase {
  final ExchangeRepository repository;
  UpdateSessionStatusUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required SessionEntity session,
    required String uid,
    required String status,
  }) async {
    if (!session.canChangeTo(uid, status)) {
      return const Left(ValidationFailure('Action non autorisée'));
    }
    return repository.updateSessionStatus(
      sessionId: session.id,
      status: status,
    );
  }
}