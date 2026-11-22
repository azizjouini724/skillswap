import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/chat/domain/repositories/chat_repository.dart';

class MarkChatReadUseCase {
  final ChatRepository repository;
  MarkChatReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String chatId,
    required String uid,
  }) {
    return repository.markRead(chatId: chatId, uid: uid);
  }
}