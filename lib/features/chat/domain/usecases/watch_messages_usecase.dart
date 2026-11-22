import 'package:skillswap/features/chat/domain/entities/message_entity.dart';
import 'package:skillswap/features/chat/domain/repositories/chat_repository.dart';

class WatchMessagesUseCase {
  final ChatRepository repository;
  WatchMessagesUseCase(this.repository);

  /// Du plus ancien au plus récent.
  Stream<List<MessageEntity>> call(String chatId) {
    return repository.watchMessages(chatId).map((list) {
      final sorted = [...list]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return sorted;
    });
  }
}