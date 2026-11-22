import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<List<NotificationEntity>> watch(String uid);

  Future<Either<Failure, Unit>> create({
    required String toUid,
    required String fromUid,
    required String type,
    required String title,
    required String body,
  });

  Future<Either<Failure, Unit>> markRead(List<String> ids);
}