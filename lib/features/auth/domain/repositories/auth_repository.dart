import 'package:dartz/dartz.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<Either<Failure, Unit>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, Unit>> resetPassword(String email);
}