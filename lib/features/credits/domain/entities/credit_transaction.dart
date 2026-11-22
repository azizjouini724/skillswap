import 'package:equatable/equatable.dart';

class CreditKind {
  static const bonus = 'bonus';
  static const teach = 'teach';
  static const learn = 'learn';
}

class CreditTransaction extends Equatable {
  final String id;
  final String kind;
  final int delta;
  final String label;
  final DateTime createdAt;

  const CreditTransaction({
    required this.id,
    required this.kind,
    required this.delta,
    required this.label,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, kind, delta, label, createdAt];
}