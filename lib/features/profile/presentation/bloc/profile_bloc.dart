import 'dart:async';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/profile/domain/usecases/add_skill_usecase.dart';
import 'package:skillswap/features/profile/domain/usecases/remove_skill_usecase.dart';
import 'package:skillswap/features/profile/domain/usecases/update_photo_usecase.dart';
import 'package:skillswap/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:skillswap/features/profile/domain/usecases/watch_profile_usecase.dart';
import 'package:skillswap/features/skills/domain/entities/skill_type.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final WatchProfileUseCase watchProfile;
  final UpdateProfileUseCase updateProfile;
  final AddSkillUseCase addSkill;
  final RemoveSkillUseCase removeSkill;
  final UpdatePhotoUseCase updatePhoto;

  StreamSubscription<ProfileEntity?>? _subscription;
  ProfileEntity? profile;

  ProfileBloc({
    required this.watchProfile,
    required this.updateProfile,
    required this.addSkill,
    required this.removeSkill,
    required this.updatePhoto,
  }) : super(const ProfileLoading()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileReceived>(_onReceived);
    on<ProfileStreamFailed>(_onStreamFailed);
    on<ProfileSaveRequested>(_onSave);
    on<SkillAdded>(_onSkillAdded);
    on<SkillRemoved>(_onSkillRemoved);
    on<PhotoChanged>(_onPhotoChanged);
    on<PhotoRemoved>(_onPhotoRemoved);
  }

  Future<void> _onStarted(
      ProfileStarted event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    await _subscription?.cancel();
    _subscription = watchProfile(event.uid).listen(
      (p) => add(ProfileReceived(p)),
      onError: (_) => add(const ProfileStreamFailed()),
    );
  }

  void _onReceived(ProfileReceived event, Emitter<ProfileState> emit) {
    profile = event.profile;
    emit(event.profile == null
        ? const ProfileFailure('Profil introuvable')
        : ProfileLoaded(event.profile!));
  }

  void _onStreamFailed(ProfileStreamFailed event, Emitter<ProfileState> emit) {
    emit(const ProfileFailure('Impossible de charger le profil'));
  }

  Future<void> _onSave(
      ProfileSaveRequested event, Emitter<ProfileState> emit) async {
    final current = profile;
    if (current == null) return;
    final result = await updateProfile(
      uid: current.uid,
      name: event.name,
      bio: event.bio,
      city: event.city,
    );
    result.fold((failure) {
      emit(ProfileActionFailed(failure.message));
      emit(ProfileLoaded(current));
    }, (_) {});
  }

  Future<void> _onSkillAdded(
      SkillAdded event, Emitter<ProfileState> emit) async {
    final current = profile;
    if (current == null) return;
    final result = await addSkill(
      profile: current,
      type: event.type,
      skill: event.skill,
    );
    result.fold((failure) {
      emit(ProfileActionFailed(failure.message));
      emit(ProfileLoaded(current));
    }, (_) {});
  }

  Future<void> _onSkillRemoved(
      SkillRemoved event, Emitter<ProfileState> emit) async {
    final current = profile;
    if (current == null) return;
    final result = await removeSkill(
      uid: current.uid,
      type: event.type,
      skill: event.skill,
    );
    result.fold((failure) {
      emit(ProfileActionFailed(failure.message));
      emit(ProfileLoaded(current));
    }, (_) {});
  }

  Future<void> _onPhotoChanged(
      PhotoChanged event, Emitter<ProfileState> emit) async {
    final current = profile;
    if (current == null) return;
    final result = await updatePhoto(uid: current.uid, bytes: event.bytes);
    result.fold((failure) {
      emit(ProfileActionFailed(failure.message));
      emit(ProfileLoaded(current));
    }, (_) {});
  }

  Future<void> _onPhotoRemoved(
      PhotoRemoved event, Emitter<ProfileState> emit) async {
    final current = profile;
    if (current == null) return;
    final result = await updatePhoto(uid: current.uid);
    result.fold((failure) {
      emit(ProfileActionFailed(failure.message));
      emit(ProfileLoaded(current));
    }, (_) {});
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}