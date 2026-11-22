import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> watch(String uid);
  Future<void> create({
    required String toUid,
    required String fromUid,
    required String type,
    required String title,
    required String body,
  });
  Future<void> markRead(List<String> ids);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;
  NotificationRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('notifications');

  @override
  Stream<List<NotificationModel>> watch(String uid) {
    return _col.where('toUid', isEqualTo: uid).snapshots().map((snap) => snap
        .docs
        .map((d) => NotificationModel.fromMap(d.data(), d.id))
        .toList());
  }

  @override
  Future<void> create({
    required String toUid,
    required String fromUid,
    required String type,
    required String title,
    required String body,
  }) {
    return _col.add({
      'toUid': toUid,
      'fromUid': fromUid,
      'type': type,
      'title': title,
      'body': body,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markRead(List<String> ids) {
    final batch = firestore.batch();
    for (final id in ids) {
      batch.update(_col.doc(id), {'read': true});
    }
    return batch.commit();
  }
}