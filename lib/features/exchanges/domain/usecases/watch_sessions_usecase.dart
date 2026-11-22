import 'package:skillswap/features/exchanges/domain/entities/session_entity.dart';
import 'package:skillswap/features/exchanges/domain/repositories/exchange_repository.dart';

class WatchSessionsUseCase {
  final ExchangeRepository repository;
  WatchSessionsUseCase(this.repository);

  /// Par date de début croissante.
  Stream<List<SessionEntity>> call(String uid) {
    return repository.watchSessions(uid).map((list) {
      final sorted = [...list]
        ..sort((a, b) => a.startAt.compareTo(b.startAt));
      return sorted;
    });
  }
}