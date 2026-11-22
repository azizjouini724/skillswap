import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String email) {
    return repository.resetPassword(email);
  }
}