import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/features/credits/domain/entities/credit_transaction.dart';

class CreditTransactionModel extends CreditTransaction {
  const CreditTransactionModel({
    required super.id,
    required super.kind,
    required super.delta,
    required super.label,
    required super.createdAt,
  });

  factory CreditTransactionModel.fromMap(Map<String, dynamic> map, String id) {
    final createdAt = map['createdAt'];
    return CreditTransactionModel(
      id: id,
      kind: map['kind'] as String? ?? CreditKind.teach,
      delta: (map['delta'] as num?)?.toInt() ?? 0,
      label: map['label'] as String? ?? '',
      // Vaut null tant que l'horodatage serveur n'est pas confirmé.
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}