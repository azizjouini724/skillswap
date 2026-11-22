part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthUserChanged extends AuthEvent {
  final UserEntity? user;
  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const SignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class PasswordResetRequested extends AuthEvent {
  final String email;
  const PasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}