import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/account.dart';

void main() {
  group('Account Model Tests', () {
    test('should create account with default values', () {
      const account = Account();

      expect(account.id, '');
      expect(account.email, '');
      expect(account.role, 'user');
    });

    test('should create account with custom values', () {
      const account = Account(
        id: 'user123',
        email: 'john.doe@example.com',
        role: 'admin',
      );

      expect(account.id, 'user123');
      expect(account.email, 'john.doe@example.com');
      expect(account.role, 'admin');
    });

    test('should copy with new role', () {
      const original = Account(id: 'user1', email: 'a@x.com', role: 'user');

      final copied = original.copyWith(role: 'admin');

      expect(copied.role, 'admin');
      expect(copied.id, 'user1');
      expect(copied.email, 'a@x.com');
      expect(original.role, 'user');
    });

    test('should round-trip through JSON', () {
      const account = Account(
        id: 'user789',
        email: 'alice@example.com',
        role: 'admin',
      );

      final json = account.toJson();
      expect(json['id'], 'user789');
      expect(json['email'], 'alice@example.com');
      expect(json['role'], 'admin');

      final deserialized = Account.fromJson(json);
      expect(deserialized, equals(account));
    });

    test('should use defaults for missing JSON fields', () {
      final account = Account.fromJson({'id': 'minimal_user'});

      expect(account.id, 'minimal_user');
      expect(account.email, '');
      expect(account.role, 'user');
    });

    test('should be equal when all fields match', () {
      const account1 = Account(id: 'a', email: 'a@x.com', role: 'user');
      const account2 = Account(id: 'a', email: 'a@x.com', role: 'user');

      expect(account1, equals(account2));
    });
  });
}
