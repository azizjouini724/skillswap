import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;
  SignInUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String email,
    required String password,
  }) {
    return repository.signIn(email: email, password: password);
  }
}