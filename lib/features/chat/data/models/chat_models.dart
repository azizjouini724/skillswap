import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/features/chat/domain/entities/chat_entity.dart';
import 'package:skillswap/features/chat/domain/entities/message_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.participantIds,
    super.names,
    super.lastMessage,
    super.lastSenderId,
    super.lastMessageAt,
    super.readAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    final rawAt = map['lastMessageAt'];
    DateTime? lastAt;
    if (rawAt is Timestamp) {
      lastAt = rawAt.toDate();
    } else if (map.containsKey('lastMessageAt')) {
      // Timestamp serveur encore en attente juste après l'envoi.
      lastAt = DateTime.now();
    }

    final readRaw = (map['readAt'] as Map?) ?? const {};
    final readAt = <String, DateTime>{
      for (final e in readRaw.entries)
        e.key as String:
            e.value is Timestamp ? (e.value as Timestamp).toDate() : DateTime.now(),
    };

    return ChatModel(
      id: id,
      participantIds: List<String>.from(map['participantIds'] ?? const []),
      names: Map<String, String>.from((map['names'] as Map?) ?? const {}),
      lastMessage: map['lastMessage'] ?? '',
      lastSenderId: map['lastSenderId'] ?? '',
      lastMessageAt: lastAt,
      readAt: readAt,
    );
  }
}

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.text,
    required super.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    final ts = map['createdAt'];
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}