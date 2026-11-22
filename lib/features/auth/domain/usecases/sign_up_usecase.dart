import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return repository.signUp(name: name, email: email, password: password);
  }
}