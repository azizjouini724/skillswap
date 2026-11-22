import 'package:equatable/equatable.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

class MatchEntity extends Equatable {
  final ProfileEntity profile;

  /// Ce que TU veux apprendre et que l'autre enseigne.
  final List<String> youLearn;

  /// Ce que TU enseignes et que l'autre veut apprendre.
  final List<String> youTeach;

  const MatchEntity({
    required this.profile,
    required this.youLearn,
    required this.youTeach,
  });

  int get score => youLearn.length + youTeach.length;

  @override
  List<Object?> get props => [profile, youLearn, youTeach];
}