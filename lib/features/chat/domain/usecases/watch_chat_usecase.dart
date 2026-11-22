import 'package:skillswap/features/chat/domain/entities/chat_entity.dart';
import 'package:skillswap/features/chat/domain/repositories/chat_repository.dart';

class WatchChatUseCase {
  final ChatRepository repository;
  WatchChatUseCase(this.repository);

  Stream<ChatEntity?> call(String chatId) => repository.watchChat(chatId);
}