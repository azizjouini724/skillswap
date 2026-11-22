import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/domain/repositories/exchange_repository.dart';

class UpdateExchangeStatusUseCase {
  final ExchangeRepository repository;
  UpdateExchangeStatusUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required ExchangeEntity exchange,
    required String uid,
    required String status,
  }) async {
    if (!exchange.canChangeTo(uid, status)) {
      return const Left(ValidationFailure('Action non autorisée'));
    }
    return repository.updateExchangeStatus(
      exchangeId: exchange.id,
      status: status,
    );
  }
}