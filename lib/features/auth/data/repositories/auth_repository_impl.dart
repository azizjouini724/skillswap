import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillswap/core/error/failures.dart';
import 'package:skillswap/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:skillswap/features/auth/domain/entities/user_entity.dart';
import 'package:skillswap/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Stream<UserEntity?> get authStateChanges => remote.authStateChanges;

  @override
  Future<Either<Failure, Unit>> signIn({
    required String email,
    required String password,
  }) {
    return _guard(() => remote.signIn(email, password));
  }

  @override
  Future<Either<Failure, Unit>> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _guard(() => remote.signUp(name, email, password));
  }

  @override
  Future<Either<Failure, Unit>> signOut() => _guard(remote.signOut);

  @override
  Future<Either<Failure, Unit>> resetPassword(String email) {
    return _guard(() => remote.resetPassword(email));
  }

  Future<Either<Failure, Unit>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_authMessage(e.code)));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Erreur serveur'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  String _authMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Adresse email invalide';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum)';
      case 'too-many-requests':
        return 'Trop de tentatives, réessaie plus tard';
      case 'network-request-failed':
        return 'Pas de connexion internet';
      default:
        return "Erreur d'authentification ($code)";
    }
  }
}