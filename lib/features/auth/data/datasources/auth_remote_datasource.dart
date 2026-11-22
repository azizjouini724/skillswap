import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/core/services/auth_service.dart';
import 'package:skillswap/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<void> signIn(String email, String password);
  Future<void> signUp(String name, String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthService authService;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.authService,
    required this.firestore,
  });

  @override
  Stream<UserModel?> get authStateChanges {
    return authService.userChanges.map(
      (user) => user == null ? null : UserModel.fromFirebaseAuth(user),
    );
  }

  @override
  Future<void> signIn(String email, String password) async {
    await authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signUp(String name, String email, String password) async {
    final credential = await authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);
    await user.reload();

    final model = UserModel(uid: user.uid, name: name, email: email);
    await firestore.collection('users').doc(user.uid).set(model.toMap());
  }

  @override
  Future<void> signOut() => authService.signOut();

  @override
  Future<void> resetPassword(String email) {
    return authService.sendPasswordResetEmail(email);
  }
}