import 'package:skillswap/features/notifications/domain/entities/notification_entity.dart';
import 'package:skillswap/features/notifications/domain/repositories/notification_repository.dart';

class WatchNotificationsUseCase {
  final NotificationRepository repository;
  WatchNotificationsUseCase(this.repository);

  /// Les plus récentes d'abord.
  Stream<List<NotificationEntity>> call(String uid) {
    return repository.watch(uid).map((list) {
      final sorted = [...list]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sorted;
    });
  }
}
