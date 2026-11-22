import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/chat/domain/entities/chat_entity.dart';
import 'package:skillswap/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatEntity>> watchChats(String uid);
  Stream<ChatEntity?> watchChat(String chatId);
  Stream<List<MessageEntity>> watchMessages(String chatId);

  Future<Either<Failure, Unit>> ensureChat({
    required String chatId,
    required List<String> participantIds,
    required Map<String, String> names,
  });

  Future<Either<Failure, Unit>> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  });

  Future<Either<Failure, Unit>> markRead({
    required String chatId,
    required String uid,
  });
}