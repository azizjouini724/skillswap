import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  Future<Either<Failure, Unit>> call() => repository.signOut();
}