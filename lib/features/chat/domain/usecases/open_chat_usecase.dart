import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/chat/domain/entities/chat_entity.dart';
import 'package:skillswap/features/chat/domain/repositories/chat_repository.dart';

class OpenChatUseCase {
  final ChatRepository repository;
  OpenChatUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String uid,
    required String myName,
    required String otherUid,
    required String otherName,
  }) async {
    if (uid.isEmpty || otherUid.isEmpty || uid == otherUid) {
      return const Left(ValidationFailure('Conversation invalide'));
    }
    return repository.ensureChat(
      chatId: ChatEntity.idFor(uid, otherUid),
      participantIds: ChatEntity.sortedIds(uid, otherUid),
      names: {
        uid: myName.trim().isEmpty ? 'User' : myName.trim(),
        otherUid: otherName.trim().isEmpty ? 'User' : otherName.trim(),
      },
    );
  }
}