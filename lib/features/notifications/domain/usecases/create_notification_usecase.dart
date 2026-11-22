import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/notifications/domain/repositories/notification_repository.dart';

class CreateNotificationUseCase {
  final NotificationRepository repository;
  CreateNotificationUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String toUid,
    required String fromUid,
    required String type,
    required String title,
    required String body,
  }) async {
    if (toUid.isEmpty || fromUid.isEmpty || toUid == fromUid) {
      return const Left(ValidationFailure('Destinataire invalide'));
    }
    final t = title.trim();
    if (t.isEmpty) {
      return const Left(ValidationFailure('Titre vide'));
    }
    final b = body.trim();

    return repository.create(
      toUid: toUid,
      fromUid: fromUid,
      type: type,
      title: t.length > 80 ? t.substring(0, 80) : t,
      body: b.length > 200 ? b.substring(0, 200) : b,
    );
  }
}