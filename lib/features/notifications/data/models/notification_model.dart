import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.toUid,
    required super.fromUid,
    required super.type,
    required super.title,
    required super.body,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    final ts = map['createdAt'];
    return NotificationModel(
      id: id,
      toUid: map['toUid'] ?? '',
      fromUid: map['fromUid'] ?? '',
      type: map['type'] ?? NotificationType.exchange,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      isRead: map['read'] == true,
      // Juste après l'écriture, le timestamp serveur peut être encore null.
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}