import 'package:equatable/equatable.dart';

class CompletedSessionRef extends Equatable {
  final String id;
  final String exchangeId;

  const CompletedSessionRef({required this.id, required this.exchangeId});

  @override
  List<Object?> get props => [id, exchangeId];
}