import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/chat/domain/entities/chat_entity.dart';
import 'package:skillswap/features/chat/domain/entities/message_entity.dart';
import 'package:skillswap/features/chat/domain/repositories/chat_repository.dart';
import 'package:skillswap/features/chat/domain/usecases/open_chat_usecase.dart';
import 'package:skillswap/features/chat/domain/usecases/send_message_usecase.dart';

class FakeChatRepository implements ChatRepository {
  int sent = 0;
  int opened = 0;
  String lastText = '';
  String lastChatId = '';

  @override
  Stream<List<ChatEntity>> watchChats(String uid) => const Stream.empty();

  @override
  Stream<ChatEntity?> watchChat(String chatId) => const Stream.empty();

  @override
  Stream<List<MessageEntity>> watchMessages(String chatId) =>
      const Stream.empty();

  @override
  Future<Either<Failure, Unit>> ensureChat({
    required String chatId,
    required List<String> participantIds,
    required Map<String, String> names,
  }) async {
    opened++;
    lastChatId = chatId;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    sent++;
    lastText = text;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> markRead({
    required String chatId,
    required String uid,
  }) async =>
      const Right(unit);
}

void main() {
  group('ChatEntity', () {
    test("l'identifiant est le même dans les deux sens", () {
      expect(ChatEntity.idFor('sara', 'ahmed'), ChatEntity.idFor('ahmed', 'sara'));
      expect(ChatEntity.idFor('sara', 'ahmed'), 'ahmed_sara');
    });

    ChatEntity chat({
      String lastSender = 'ahmed',
      Map<String, DateTime> readAt = const {},
    }) =>
        ChatEntity(
          id: 'ahmed_sara',
          participantIds: const ['ahmed', 'sara'],
          lastMessage: 'Hi',
          lastSenderId: lastSender,
          lastMessageAt: DateTime(2026, 11, 22, 12),
          readAt: readAt,
        );

    test("non lu : message de l'autre jamais lu", () {
      expect(chat().isUnreadFor('sara'), true);
    });

    test("lu : j'ai lu après le dernier message", () {
      final c = chat(readAt: {'sara': DateTime(2026, 11, 22, 13)});
      expect(c.isUnreadFor('sara'), false);
    });

    test("mon propre message n'est jamais non lu", () {
      expect(chat(lastSender: 'sara').isUnreadFor('sara'), false);
    });
  });

  group('SendMessageUseCase', () {
    late FakeChatRepository repo;
    late SendMessageUseCase useCase;

    setUp(() {
      repo = FakeChatRepository();
      useCase = SendMessageUseCase(repo);
    });

    test('refuse un message vide', () async {
      final result =
          await useCase(chatId: 'a_b', senderId: 'a', text: '   ');
      expect(result.isLeft(), true);
      expect(repo.sent, 0);
    });

    test('refuse un message de plus de 1000 caractères', () async {
      final result =
          await useCase(chatId: 'a_b', senderId: 'a', text: 'x' * 1001);
      expect(result.isLeft(), true);
      expect(repo.sent, 0);
    });

    test('envoie un message valide sans les espaces autour', () async {
      final result =
          await useCase(chatId: 'a_b', senderId: 'a', text: '  Hello  ');
      expect(result.isRight(), true);
      expect(repo.lastText, 'Hello');
    });
  });

  group('OpenChatUseCase', () {
    late FakeChatRepository repo;
    late OpenChatUseCase useCase;

    setUp(() {
      repo = FakeChatRepository();
      useCase = OpenChatUseCase(repo);
    });

    test('refuse une conversation avec soi-même', () async {
      final result = await useCase(
          uid: 'ahmed', myName: 'Ahmed', otherUid: 'ahmed', otherName: 'Ahmed');
      expect(result.isLeft(), true);
      expect(repo.opened, 0);
    });

    test("ouvre une conversation avec l'identifiant trié", () async {
      final result = await useCase(
          uid: 'sara', myName: 'Sara', otherUid: 'ahmed', otherName: 'Ahmed');
      expect(result.isRight(), true);
      expect(repo.lastChatId, 'ahmed_sara');
    });
  });
}