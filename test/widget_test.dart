import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/features/auth/domain/entities/user_entity.dart';

void main() {
  test('UserEntity est comparée par valeur (Equatable)', () {
    const a = UserEntity(uid: '1', name: 'Ahmed', email: 'a@a.com');
    const b = UserEntity(uid: '1', name: 'Ahmed', email: 'a@a.com');
    expect(a, equals(b));
  });
}