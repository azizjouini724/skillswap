import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/profile/domain/repositories/profile_repository.dart';

class WatchProfileUseCase {
  final ProfileRepository repository;
  WatchProfileUseCase(this.repository);

  Stream<ProfileEntity?> call(String uid) => repository.watchProfile(uid);
}