import 'package:skillswap/features/auth/domain/entities/user_entity.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class WatchAuthStateUseCase {
  final AuthRepository repository;
  WatchAuthStateUseCase(this.repository);

  Stream<UserEntity?> call() => repository.authStateChanges;
}