import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:skillswap/features/notifications/domain/entities/notification_entity.dart';
import 'package:skillswap/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remote;
  NotificationRepositoryImpl(this.remote);

  @override
  Stream<List<NotificationEntity>> watch(String uid) => remote.watch(uid);

  @override
  Future<Either<Failure, Unit>> create({
    required String toUid,
    required String fromUid,
    required String type,
    required String title,
    required String body,
  }) {
    return _guard(() => remote.create(
          toUid: toUid,
          fromUid: fromUid,
          type: type,
          title: title,
          body: body,
        ));
  }

  @override
  Future<Either<Failure, Unit>> markRead(List<String> ids) {
    return _guard(() => remote.markRead(ids));
  }

  Future<Either<Failure, Unit>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Right(unit);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return const Left(ServerFailure('Action non autorisée'));
      }
      if (e.code == 'unavailable') return const Left(NetworkFailure());
      return Left(ServerFailure(e.message ?? 'Erreur serveur'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}