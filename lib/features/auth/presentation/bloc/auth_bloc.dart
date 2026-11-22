import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/auth/domain/entities/user_entity.dart';
import 'package:skillswap/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:skillswap/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:skillswap/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:skillswap/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:skillswap/features/auth/domain/usecases/watch_auth_state_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final WatchAuthStateUseCase watchAuthState;
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final ResetPasswordUseCase resetPassword;

  StreamSubscription<UserEntity?>? _subscription;

  /// Lus par le routeur pour décider des redirections.
  bool initialized = false;
  UserEntity? currentUser;

  AuthBloc({
    required this.watchAuthState,
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.resetPassword,
  }) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthUserChanged>(_onUserChanged);
    on<SignInRequested>(_onSignIn);
    on<SignUpRequested>(_onSignUp);
    on<SignOutRequested>(_onSignOut);
    on<PasswordResetRequested>(_onResetPassword);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await _subscription?.cancel();
    _subscription = watchAuthState().listen((user) {
      add(AuthUserChanged(user));
    });
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    initialized = true;
    currentUser = event.user;
    emit(event.user == null
        ? const Unauthenticated()
        : Authenticated(event.user!));
  }

  Future<void> _onSignIn(
      SignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signIn(email: event.email, password: event.password);
    result.fold((failure) => emit(AuthError(failure.message)), (_) {});
  }

  Future<void> _onSignUp(
      SignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signUp(
      name: event.name,
      email: event.email,
      password: event.password,
    );
    result.fold((failure) => emit(AuthError(failure.message)), (_) {});
  }

  Future<void> _onSignOut(
      SignOutRequested event, Emitter<AuthState> emit) async {
    final result = await signOut();
    result.fold((failure) => emit(AuthError(failure.message)), (_) {});
  }

  Future<void> _onResetPassword(
      PasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await resetPassword(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const PasswordResetSent()),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}