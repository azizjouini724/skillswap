import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/features/exchanges/domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.exchangeId,
    required super.hostId,
    required super.participantIds,
    required super.startAt,
    required super.durationMinutes,
    required super.meetingMode,
    required super.status,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map, String id) {
    final start = map['startAt'];
    return SessionModel(
      id: id,
      exchangeId: map['exchangeId'] ?? '',
      hostId: map['hostId'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? const []),
      startAt: start is Timestamp ? start.toDate() : DateTime.now(),
      durationMinutes: (map['durationMinutes'] ?? 60) as int,
      meetingMode: map['meetingMode'] ?? '',
      status: map['status'] ?? '',
    );
  }
}