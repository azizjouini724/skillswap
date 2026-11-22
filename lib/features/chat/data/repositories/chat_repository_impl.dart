import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:skillswap/features/chat/domain/entities/chat_entity.dart';
import 'package:skillswap/features/chat/domain/entities/message_entity.dart';
import 'package:skillswap/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;
  ChatRepositoryImpl(this.remote);

  @override
  Stream<List<ChatEntity>> watchChats(String uid) => remote.watchChats(uid);

  @override
  Stream<ChatEntity?> watchChat(String chatId) => remote.watchChat(chatId);

  @override
  Stream<List<MessageEntity>> watchMessages(String chatId) =>
      remote.watchMessages(chatId);

  @override
  Future<Either<Failure, Unit>> ensureChat({
    required String chatId,
    required List<String> participantIds,
    required Map<String, String> names,
  }) {
    return _guard(() => remote.ensureChat(
          chatId: chatId,
          participantIds: participantIds,
          names: names,
        ));
  }

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) {
    return _guard(() => remote.sendMessage(
          chatId: chatId,
          senderId: senderId,
          text: text,
        ));
  }

  @override
  Future<Either<Failure, Unit>> markRead({
    required String chatId,
    required String uid,
  }) {
    return _guard(() => remote.markRead(chatId: chatId, uid: uid));
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