import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/domain/repositories/exchange_repository.dart';

class WatchExchangesUseCase {
  final ExchangeRepository repository;
  WatchExchangesUseCase(this.repository);

  /// Les plus récentes d'abord.
  Stream<List<ExchangeEntity>> call(String uid) {
    return repository.watchExchanges(uid).map((list) {
      final sorted = [...list]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sorted;
    });
  }
}