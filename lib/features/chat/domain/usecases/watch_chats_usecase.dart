import 'package:skillswap/features/chat/domain/entities/chat_entity.dart';
import 'package:skillswap/features/chat/domain/repositories/chat_repository.dart';

class WatchChatsUseCase {
  final ChatRepository repository;
  WatchChatsUseCase(this.repository);

  /// Seulement les conversations qui ont des messages, la plus récente d'abord.
  Stream<List<ChatEntity>> call(String uid) {
    return repository.watchChats(uid).map((list) {
      final withMessages = list.where((c) => c.hasMessages).toList()
        ..sort((a, b) => b.lastMessageAt!.compareTo(a.lastMessageAt!));
      return withMessages;
    });
  }
}