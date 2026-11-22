part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Erreur bloquante (profil introuvable, flux interrompu).
class ProfileFailure extends ProfileState {
  final String message;
  const ProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Erreur ponctuelle d'une action : affichée en SnackBar, puis on
/// réémet ProfileLoaded.
class ProfileActionFailed extends ProfileState {
  final String message;
  const ProfileActionFailed(this.message);

  @override
  List<Object?> get props => [message];
}