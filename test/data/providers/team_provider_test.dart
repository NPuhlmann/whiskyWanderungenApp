import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/providers/team_provider.dart';
import 'package:whisky_hikes/data/services/team/team_management_service.dart';
import 'package:whisky_hikes/domain/models/account.dart';

import '../../mocks/mock_repositories.dart';

/// Test-Double für [TeamManagementService] ohne Supabase-Abhängigkeit.
/// Deckt nur `setUserRole` ab - das Laden der Liste läuft über
/// [MockUserRepository.listAccounts].
class _FakeTeamService implements TeamManagementService {
  Object? setRoleError;
  Account Function(String userId, String newRole)? roleUpdater;

  @override
  Future<Account> setUserRole({
    required String userId,
    required String newRole,
  }) async {
    if (setRoleError != null) throw setRoleError!;
    final updater =
        roleUpdater ??
        (id, role) => Account(id: id, email: '$id@x', role: role);
    return updater(userId, newRole);
  }
}

Account _account(String id, String email, {String role = 'user'}) =>
    Account(id: id, email: email, role: role);

void main() {
  group('TeamProvider', () {
    late MockUserRepository mockUserRepository;
    late _FakeTeamService fakeService;

    setUp(() {
      mockUserRepository = MockUserRepository();
      fakeService = _FakeTeamService();
    });

    TeamProvider buildProvider() =>
        TeamProvider(userRepository: mockUserRepository, service: fakeService);

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
      fakeService.setRoleError = Exception('forbidden');
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
