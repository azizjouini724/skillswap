import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';

class ExchangeModel extends ExchangeEntity {
  const ExchangeModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.senderName,
    required super.receiverName,
    required super.offeredSkill,
    required super.requestedSkill,
    super.message,
    required super.status,
    required super.createdAt,
  });

  factory ExchangeModel.fromMap(Map<String, dynamic> map, String id) {
    final created = map['createdAt'];
    return ExchangeModel(
      id: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverName: map['receiverName'] ?? '',
      offeredSkill: map['offeredSkill'] ?? '',
      requestedSkill: map['requestedSkill'] ?? '',
      message: map['message'] ?? '',
      status: map['status'] ?? '',
      // null tant que le serveur n'a pas résolu le timestamp.
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }
}