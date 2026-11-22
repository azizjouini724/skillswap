import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final t = text.trim();
    if (t.isEmpty) {
      return const Left(ValidationFailure('Message vide'));
    }
    if (t.length > 1000) {
      return const Left(ValidationFailure('Message trop long (1000 max)'));
    }
    return repository.sendMessage(chatId: chatId, senderId: senderId, text: t);
  }
}