import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/features/profile/data/models/profile_model.dart';

abstract class DiscoverRemoteDataSource {
  Future<List<ProfileModel>> fetchProfiles({required int limit});
}

class DiscoverRemoteDataSourceImpl implements DiscoverRemoteDataSource {
  final FirebaseFirestore firestore;
  DiscoverRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<ProfileModel>> fetchProfiles({required int limit}) async {
    final snapshot = await firestore.collection('users').limit(limit).get();
    return snapshot.docs
        .map((doc) => ProfileModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}