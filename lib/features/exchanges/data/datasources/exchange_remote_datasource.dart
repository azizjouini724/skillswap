import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/features/exchanges/data/models/exchange_model.dart';
import 'package:skillswap/features/exchanges/data/models/session_model.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_status.dart';

abstract class ExchangeRemoteDataSource {
  Stream<List<ExchangeModel>> watchExchanges(String uid);
  Stream<List<SessionModel>> watchSessions(String uid);
  Future<void> sendRequest({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String offeredSkill,
    required String requestedSkill,
    required String message,
  });
  Future<void> updateExchangeStatus(String exchangeId, String status);
  Future<void> proposeSession({
    required String exchangeId,
    required String hostId,
    required List<String> participantIds,
    required DateTime startAt,
    required int durationMinutes,
    required String meetingMode,
  });
  Future<void> updateSessionStatus(String sessionId, String status);
  Future<void> counterProposeSession({
    required String sessionId,
    required String uid,
    required DateTime startAt,
    required int durationMinutes,
    required String meetingMode,
  });
}

class ExchangeRemoteDataSourceImpl implements ExchangeRemoteDataSource {
  final FirebaseFirestore firestore;
  ExchangeRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _exchanges =>
      firestore.collection('exchanges');
  CollectionReference<Map<String, dynamic>> get _sessions =>
      firestore.collection('sessions');

  @override
  Stream<List<ExchangeModel>> watchExchanges(String uid) {
    return _exchanges
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ExchangeModel.fromMap(d.data(), d.id))
            .toList());
  }

  @override
  Stream<List<SessionModel>> watchSessions(String uid) {
    return _sessions
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SessionModel.fromMap(d.data(), d.id))
            .toList());
  }

  @override
  Future<void> sendRequest({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String offeredSkill,
    required String requestedSkill,
    required String message,
  }) {
    return _exchanges.add({
      'senderId': senderId,
      'receiverId': receiverId,
      'participantIds': [senderId, receiverId],
      'senderName': senderName,
      'receiverName': receiverName,
      'offeredSkill': offeredSkill,
      'requestedSkill': requestedSkill,
      'message': message,
      'status': ExchangeStatus.pending,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateExchangeStatus(String exchangeId, String status) {
    return _exchanges.doc(exchangeId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> proposeSession({
    required String exchangeId,
    required String hostId,
    required List<String> participantIds,
    required DateTime startAt,
    required int durationMinutes,
    required String meetingMode,
  }) {
    return _sessions.add({
      'exchangeId': exchangeId,
      'hostId': hostId,
      'participantIds': participantIds,
      'startAt': Timestamp.fromDate(startAt),
      'durationMinutes': durationMinutes,
      'meetingMode': meetingMode,
      'status': SessionStatus.proposed,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateSessionStatus(String sessionId, String status) {
    return _sessions.doc(sessionId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
    @override
  Future<void> counterProposeSession({
    required String sessionId,
    required String uid,
    required DateTime startAt,
    required int durationMinutes,
    required String meetingMode,
  }) {
    return _sessions.doc(sessionId).update({
      'hostId': uid,
      'startAt': Timestamp.fromDate(startAt),
      'durationMinutes': durationMinutes,
      'meetingMode': meetingMode,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  

  
}