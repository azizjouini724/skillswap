import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PresenceRemoteDataSource {
  Future<void> touch(String uid);
}

class PresenceRemoteDataSourceImpl implements PresenceRemoteDataSource {
  final FirebaseFirestore firestore;
  PresenceRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> touch(String uid) {
    // update (et non set) : on ne crée jamais un profil incomplet.
    return firestore.collection('users').doc(uid).update({
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
}