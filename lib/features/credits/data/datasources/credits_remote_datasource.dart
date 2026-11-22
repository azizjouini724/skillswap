import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/features/credits/data/models/credit_transaction_model.dart';
import 'package:skillswap/features/credits/domain/entities/completed_session_ref.dart';
import 'package:skillswap/features/credits/domain/entities/credit_ledger.dart';
import 'package:skillswap/features/credits/domain/entities/credit_transaction.dart';

abstract class CreditsRemoteDataSource {
  Stream<List<CreditTransactionModel>> watchTransactions(String uid);
  Stream<List<CompletedSessionRef>> watchCompletedSessions(String uid);
  Future<void> claimBonus(String uid);
  Future<void> claimSession(String uid, CompletedSessionRef session);
}

class CreditsRemoteDataSourceImpl implements CreditsRemoteDataSource {
  final FirebaseFirestore firestore;
  CreditsRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _transactions =>
      firestore.collection('transactions');

  @override
  Stream<List<CreditTransactionModel>> watchTransactions(String uid) {
    // Pas de orderBy : il demanderait un index. Le tri se fait dans le bloc.
    return _transactions.where('uid', isEqualTo: uid).snapshots().map(
          (snapshot) => snapshot.docs
              .map((d) => CreditTransactionModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  @override
  Stream<List<CompletedSessionRef>> watchCompletedSessions(String uid) {
    return firestore
        .collection('sessions')
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where((d) => d.data()['status'] == 'completed')
              .map((d) => CompletedSessionRef(
                    id: d.id,
                    exchangeId: (d.data()['exchangeId'] as String?) ?? '',
                  ))
              .toList(),
        );
  }

  @override
  Future<void> claimBonus(String uid) {
    return _transactions.doc(CreditLedger.bonusId(uid)).set({
      'uid': uid,
      'delta': CreditLedger.bonusAmount,
      'kind': CreditKind.bonus,
      'label': 'Profile completed',
      'refId': 'profile',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> claimSession(String uid, CompletedSessionRef session) async {
    var taughtSkill = 'a skill';
    var learnedSkill = 'a skill';

    // Les noms des compétences viennent de l'échange (facultatif).
    try {
      final snap =
          await firestore.collection('exchanges').doc(session.exchangeId).get();
      final data = snap.data();
      if (data != null) {
        final iAmSender = data['senderId'] == uid;
        final offered = data['offeredSkill'] as String?;
        final requested = data['requestedSkill'] as String?;
        taughtSkill = (iAmSender ? offered : requested) ?? taughtSkill;
        learnedSkill = (iAmSender ? requested : offered) ?? learnedSkill;
      }
    } catch (_) {}

    final batch = firestore.batch();
    batch.set(_transactions.doc(CreditLedger.teachId(session.id, uid)), {
      'uid': uid,
      'delta': 1,
      'kind': CreditKind.teach,
      'label': 'Taught $taughtSkill',
      'refId': session.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(_transactions.doc(CreditLedger.learnId(session.id, uid)), {
      'uid': uid,
      'delta': -1,
      'kind': CreditKind.learn,
      'label': 'Learned $learnedSkill',
      'refId': session.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}