import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationsReadUseCase {
  final NotificationRepository repository;
  MarkNotificationsReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call(List<String> ids) async {
    if (ids.isEmpty) return const Right(unit);
    return repository.markRead(ids);
  }
}