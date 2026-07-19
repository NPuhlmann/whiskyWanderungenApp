import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/providers/team_provider.dart';
import 'package:whisky_hikes/domain/models/account.dart';

import '../../mocks/mock_repositories.dart';

Account _account(String id, String email, {String role = 'user'}) =>
    Account(id: id, email: email, role: role);

void main() {
  group('TeamProvider', () {
    late MockUserRepository mockUserRepository;

    setUp(() {
      mockUserRepository = MockUserRepository();
    });

    TeamProvider buildProvider() =>
        TeamProvider(userRepository: mockUserRepository);

    test('load() füllt profiles und berechnet Counts', () async {
      when(mockUserRepository.listAccounts()).thenAnswer(
        (_) async => [
          _account('a', 'a@x', role: 'admin'),
          _account('b', 'b@x'),
          _account('c', 'c@x'),
        ],
      );
      final provider = buildProvider();

      await provider.load();

      expect(provider.profiles, hasLength(3));
      expect(provider.adminCount, 1);
      expect(provider.userCount, 2);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('load() setzt error und leert profiles bei Service-Fehler', () async {
      when(mockUserRepository.listAccounts()).thenThrow(Exception('boom'));
      final provider = buildProvider();

      await provider.load();

      expect(provider.profiles, isEmpty);
      expect(provider.error, contains('boom'));
      expect(provider.isLoading, isFalse);
    });

    test('setRoleFilter filtert die geladene Liste', () async {
      when(mockUserRepository.listAccounts()).thenAnswer(
        (_) async => [
          _account('a', 'a@x', role: 'admin'),
          _account('b', 'b@x'),
        ],
      );
      final provider = buildProvider();
      await provider.load();

      await provider.setRoleFilter('admin');

      expect(provider.profiles.map((a) => a.id), ['a']);
    });

    test('setSearchQuery filtert die geladene Liste', () async {
      when(mockUserRepository.listAccounts()).thenAnswer(
        (_) async => [_account('a', 'alice@x'), _account('b', 'bob@x')],
      );
      final provider = buildProvider();
      await provider.load();

      await provider.setSearchQuery('bob');

      expect(provider.profiles.map((a) => a.id), ['b']);
    });

    test('setUserRole tauscht den Account und passt Counts an', () async {
      when(
        mockUserRepository.listAccounts(),
      ).thenAnswer((_) async => [_account('a', 'a@x'), _account('b', 'b@x')]);
      when(
        mockUserRepository.setUserRole(userId: 'a', newRole: 'admin'),
      ).thenAnswer((_) async => _account('a', 'a@x', role: 'admin'));
      final provider = buildProvider();
      await provider.load();
      expect(provider.adminCount, 0);

      await provider.setUserRole(userId: 'a', newRole: 'admin');

      expect(provider.profiles.firstWhere((a) => a.id == 'a').role, 'admin');
      expect(provider.adminCount, 1);
      expect(provider.userCount, 1);
    });

    test('setUserRole setzt error und wirft Fehler weiter', () async {
      when(
        mockUserRepository.listAccounts(),
      ).thenAnswer((_) async => [_account('a', 'a@x')]);
      when(
        mockUserRepository.setUserRole(userId: 'a', newRole: 'admin'),
      ).thenThrow(Exception('forbidden'));
      final provider = buildProvider();
      await provider.load();

      await expectLater(
        provider.setUserRole(userId: 'a', newRole: 'admin'),
        throwsException,
      );
      expect(provider.error, contains('forbidden'));
    });

    test('clearError löscht den Fehlerzustand', () async {
      when(mockUserRepository.listAccounts()).thenThrow(Exception('boom'));
      final provider = buildProvider();
      await provider.load();
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
