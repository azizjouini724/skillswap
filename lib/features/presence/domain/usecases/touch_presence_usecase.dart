import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/presence/domain/repositories/presence_repository.dart';

class TouchPresenceUseCase {
  final PresenceRepository repository;
  TouchPresenceUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String uid) async {
    if (uid.isEmpty) return const Left(ValidationFailure('Missing user'));
    return repository.touch(uid);
  }
}