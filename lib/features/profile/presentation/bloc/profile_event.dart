part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  final String uid;
  const ProfileStarted(this.uid);

  @override
  List<Object?> get props => [uid];
}

class ProfileReceived extends ProfileEvent {
  final ProfileEntity? profile;
  const ProfileReceived(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileStreamFailed extends ProfileEvent {
  const ProfileStreamFailed();
}

class ProfileSaveRequested extends ProfileEvent {
  final String name;
  final String bio;
  final String city;
  const ProfileSaveRequested({
    required this.name,
    required this.bio,
    required this.city,
  });

  @override
  List<Object?> get props => [name, bio, city];
}

class SkillAdded extends ProfileEvent {
  final SkillType type;
  final String skill;
  const SkillAdded({required this.type, required this.skill});

  @override
  List<Object?> get props => [type, skill];
}

class SkillRemoved extends ProfileEvent {
  final SkillType type;
  final String skill;
  const SkillRemoved({required this.type, required this.skill});

  @override
  List<Object?> get props => [type, skill];
}
class PhotoChanged extends ProfileEvent {
  final Uint8List bytes;
  const PhotoChanged(this.bytes);

  @override
  List<Object?> get props => [bytes];
}

class PhotoRemoved extends ProfileEvent {
  const PhotoRemoved();
}