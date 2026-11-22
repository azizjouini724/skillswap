import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/notifications/domain/entities/notification_entity.dart';
import 'package:skillswap/features/notifications/domain/repositories/notification_repository.dart';
import 'package:skillswap/features/notifications/domain/usecases/create_notification_usecase.dart';

class FakeNotificationRepository implements NotificationRepository {
  int created = 0;
  String lastBody = '';

  @override
  Stream<List<NotificationEntity>> watch(String uid) => const Stream.empty();

  @override
  Future<Either<Failure, Unit>> create({
    required String toUid,
    required String fromUid,
    required String type,
    required String title,
    required String body,
  }) async {
    created++;
    lastBody = body;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> markRead(List<String> ids) async =>
      const Right(unit);
}

void main() {
  late FakeNotificationRepository repo;
  late CreateNotificationUseCase useCase;

  setUp(() {
    repo = FakeNotificationRepository();
    useCase = CreateNotificationUseCase(repo);
  });

  Future<Either<Failure, Unit>> create({
    String to = 'sara',
    String from = 'ahmed',
    String title = 'New exchange request',
    String body = 'Ahmed wants to swap Flutter for Photoshop',
  }) {
    return useCase(
      toUid: to,
      fromUid: from,
      type: NotificationType.request,
      title: title,
      body: body,
    );
  }

  test('crée une notification valide', () async {
    final result = await create();
    expect(result.isRight(), true);
    expect(repo.created, 1);
  });

  test("refuse de s'envoyer une notification à soi-même", () async {
    final result = await create(to: 'ahmed', from: 'ahmed');
    expect(result.isLeft(), true);
    expect(repo.created, 0);
  });

  test('refuse un titre vide', () async {
    final result = await create(title: '   ');
    expect(result.isLeft(), true);
    expect(repo.created, 0);
  });

  test('tronque un message trop long à 200 caractères', () async {
    await create(body: 'x' * 300);
    expect(repo.lastBody.length, 200);
  });
}