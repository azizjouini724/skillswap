import 'package:equatable/equatable.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_status.dart';

class ExchangeEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String receiverName;
  final String offeredSkill;
  final String requestedSkill;
  final String message;
  final String status;
  final DateTime createdAt;

  const ExchangeEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.receiverName,
    required this.offeredSkill,
    required this.requestedSkill,
    this.message = '',
    required this.status,
    required this.createdAt,
  });

  List<String> get participantIds => [senderId, receiverId];

  bool get isPending => status == ExchangeStatus.pending;
  bool get isAccepted => status == ExchangeStatus.accepted;

  bool involves(String uid) => uid == senderId || uid == receiverId;
  bool isSender(String uid) => uid == senderId;

  String otherName(String uid) => isSender(uid) ? receiverName : senderName;

  /// Ce que `uid` enseigne / apprend dans cet échange.
  String teachOf(String uid) => isSender(uid) ? offeredSkill : requestedSkill;
  String learnOf(String uid) => isSender(uid) ? requestedSkill : offeredSkill;

  /// Règle métier des transitions (miroir des règles Firestore).
  bool canChangeTo(String uid, String next) {
    if (!involves(uid)) return false;

    if (status == ExchangeStatus.pending) {
      if (uid == receiverId) {
        return next == ExchangeStatus.accepted ||
            next == ExchangeStatus.rejected;
      }
      return next == ExchangeStatus.cancelled;
    }
    if (status == ExchangeStatus.accepted) {
      return next == ExchangeStatus.completed ||
          next == ExchangeStatus.cancelled;
    }
    return false;
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        receiverId,
        senderName,
        receiverName,
        offeredSkill,
        requestedSkill,
        message,
        status,
        createdAt,
      ];
}