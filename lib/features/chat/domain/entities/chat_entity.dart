import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final String id;
  final List<String> participantIds;
  final Map<String, String> names;
  final String lastMessage;
  final String lastSenderId;
  final DateTime? lastMessageAt;
  final Map<String, DateTime> readAt;

  const ChatEntity({
    required this.id,
    required this.participantIds,
    this.names = const {},
    this.lastMessage = '',
    this.lastSenderId = '',
    this.lastMessageAt,
    this.readAt = const {},
  });

  /// Même identifiant pour A→B et B→A.
  static String idFor(String a, String b) {
    final ids = sortedIds(a, b);
    return '${ids[0]}_${ids[1]}';
  }

  static List<String> sortedIds(String a, String b) => [a, b]..sort();

  bool get hasMessages => lastMessageAt != null && lastMessage.isNotEmpty;

  String otherId(String uid) =>
      participantIds.firstWhere((p) => p != uid, orElse: () => '');

  String otherName(String uid) => names[otherId(uid)] ?? 'Unknown';

  /// Non lu : le dernier message vient de l'autre et je ne l'ai pas lu après.
  bool isUnreadFor(String uid) {
    final last = lastMessageAt;
    if (last == null || lastSenderId.isEmpty || lastSenderId == uid) {
      return false;
    }
    final read = readAt[uid];
    return read == null || read.isBefore(last);
  }

  @override
  List<Object?> get props => [
        id,
        participantIds,
        names,
        lastMessage,
        lastSenderId,
        lastMessageAt,
        readAt,
      ];
}