import 'package:skillswap/features/credits/domain/entities/completed_session_ref.dart';
import 'package:skillswap/features/credits/domain/entities/credit_transaction.dart';

class CreditLedger {
  static const bonusAmount = 50;

  // Identifiants déterministes : un mouvement ne peut exister qu'une fois.
  // Ils doivent rester identiques à ceux des règles Firestore.
  static String bonusId(String uid) => 'bonus_$uid';
  static String teachId(String sessionId, String uid) =>
      'teach_${sessionId}_$uid';
  static String learnId(String sessionId, String uid) =>
      'learn_${sessionId}_$uid';

  static int balance(List<CreditTransaction> transactions) =>
      transactions.fold(0, (sum, t) => sum + t.delta);

  static bool hasBonus(List<CreditTransaction> transactions) =>
      transactions.any((t) => t.kind == CreditKind.bonus);

  /// Séances terminées pour lesquelles il manque encore mes mouvements.
  static List<CompletedSessionRef> unclaimed({
    required String uid,
    required List<CompletedSessionRef> sessions,
    required List<CreditTransaction> transactions,
  }) {
    final owned = transactions.map((t) => t.id).toSet();
    return sessions
        .where((s) =>
            !(owned.contains(teachId(s.id, uid)) &&
                owned.contains(learnId(s.id, uid))))
        .toList();
  }
}