import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/features/chat/data/models/chat_models.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatModel>> watchChats(String uid);
  Stream<ChatModel?> watchChat(String chatId);
  Stream<List<MessageModel>> watchMessages(String chatId);
  Future<void> ensureChat({
    required String chatId,
    required List<String> participantIds,
    required Map<String, String> names,
  });
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  });
  Future<void> markRead({required String chatId, required String uid});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  ChatRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _chats =>
      firestore.collection('chats');

  @override
  Stream<List<ChatModel>> watchChats(String uid) {
    return _chats
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatModel.fromMap(d.data(), d.id))
            .toList());
  }

  @override
  Stream<ChatModel?> watchChat(String chatId) {
    return _chats.doc(chatId).snapshots().map((d) {
      final data = d.data();
      return d.exists && data != null ? ChatModel.fromMap(data, d.id) : null;
    });
  }

  @override
  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .limitToLast(100)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.data(), d.id))
            .toList());
  }

  @override
  Future<void> ensureChat({
    required String chatId,
    required List<String> participantIds,
    required Map<String, String> names,
  }) async {
    final ref = _chats.doc(chatId);
    final snap = await ref.get();
    if (snap.exists) return;
    await ref.set({'participantIds': participantIds, 'names': names});
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) {
    final chat = _chats.doc(chatId);
    final message = chat.collection('messages').doc();
    final preview = text.length > 120 ? text.substring(0, 120) : text;

    final batch = firestore.batch();
    batch.set(message, {
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(chat, {
      'lastMessage': preview,
      'lastSenderId': senderId,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'readAt.$senderId': FieldValue.serverTimestamp(),
    });
    return batch.commit();
  }

  @override
  Future<void> markRead({required String chatId, required String uid}) {
    return _chats.doc(chatId).update({
      'readAt.$uid': FieldValue.serverTimestamp(),
    });
  }
}
