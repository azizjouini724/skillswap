import 'package:equatable/equatable.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_status.dart';

class SessionEntity extends Equatable {
  final String id;
  final String exchangeId;
  final String hostId;
  final List<String> participantIds;
  final DateTime startAt;
  final int durationMinutes;
  final String meetingMode;
  final String status;

  const SessionEntity({
    required this.id,
    required this.exchangeId,
    required this.hostId,
    required this.participantIds,
    required this.startAt,
    required this.durationMinutes,
    required this.meetingMode,
    required this.status,
  });

  bool get isUpcoming =>
      status == SessionStatus.proposed || status == SessionStatus.confirmed;

  bool involves(String uid) => participantIds.contains(uid);
    /// L'autre personne (pas celle qui a fait la dernière proposition)
  /// peut proposer une autre date tant que la séance n'est pas confirmée.
  bool canCounterPropose(String uid) =>
      involves(uid) && status == SessionStatus.proposed && uid != hostId;

  bool canChangeTo(String uid, String next) {
    if (!involves(uid)) return false;

    if (status == SessionStatus.proposed) {
      if (next == SessionStatus.confirmed) return uid != hostId;
      return next == SessionStatus.cancelled;
    }
    if (status == SessionStatus.confirmed) {
      return next == SessionStatus.completed ||
          next == SessionStatus.cancelled;
    }
    return false;
  }

  @override
  List<Object?> get props => [
        id,
        exchangeId,
        hostId,
        participantIds,
        startAt,
        durationMinutes,
        meetingMode,
        status,
      ];
}