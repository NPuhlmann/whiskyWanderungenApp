import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/data/providers/team_provider.dart';
import 'package:whisky_hikes/data/services/team/team_management_service.dart';
import 'package:whisky_hikes/domain/models/profile.dart';

/// Test-Double für [TeamManagementService] ohne Supabase-Abhängigkeit.
class _FakeTeamService implements TeamManagementService {
  List<Profile> profiles;
  String? lastRoleFilter;
  String? lastSearchQuery;
  Object? listError;
  Object? setRoleError;
  Profile Function(String userId, String newRole)? roleUpdater;

  _FakeTeamService(this.profiles);

  @override
  Future<List<Profile>> listProfiles({
    String? roleFilter,
    String? searchQuery,
    int limit = 200,
  }) async {
    lastRoleFilter = roleFilter;
    lastSearchQuery = searchQuery;
    if (listError != null) throw listError!;
    Iterable<Profile> result = profiles;
    if (roleFilter != null && roleFilter.isNotEmpty) {
      result = result.where((p) => p.role == roleFilter);
    }
    final q = searchQuery?.trim().toLowerCase();
    if (q != null && q.isNotEmpty) {
      result = result.where(
        (p) =>
            p.email.toLowerCase().contains(q) ||
            p.firstName.toLowerCase().contains(q) ||
            p.lastName.toLowerCase().contains(q),
      );
    }
    return result.toList();
  }

  @override
  Future<Profile> setUserRole({
    required String userId,
    required String newRole,
  }) async {
    if (setRoleError != null) throw setRoleError!;
    final updater = roleUpdater ??
        (id, role) {
          final idx = profiles.indexWhere((p) => p.id == id);
          if (idx < 0) {
            throw StateError('No profile with id $id');
          }
          return profiles[idx].copyWith(role: role);
        };
    final updated = updater(userId, newRole);
    final idx = profiles.indexWhere((p) => p.id == userId);
    if (idx >= 0) profiles[idx] = updated;
    return updated;
  }
}

Profile _profile(String id, String email, {String role = 'user'}) => Profile(
      id: id,
      email: email,
      firstName: '',
      lastName: '',
      role: role,
    );

void main() {
  group('TeamProvider', () {
    test('load() füllt profiles und berechnet Counts', () async {
      final fake = _FakeTeamService([
        _profile('a', 'a@x', role: 'admin'),
        _profile('b', 'b@x'),
        _profile('c', 'c@x'),
      ]);
      final provider = TeamProvider(service: fake);

      await provider.load();

      expect(provider.profiles, hasLength(3));
      expect(provider.adminCount, 1);
      expect(provider.userCount, 2);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('load() setzt error und leert profiles bei Service-Fehler', () async {
      final fake = _FakeTeamService([_profile('a', 'a@x')]);
      fake.listError = Exception('boom');
      final provider = TeamProvider(service: fake);

      await provider.load();

      expect(provider.profiles, isEmpty);
      expect(provider.error, contains('boom'));
      expect(provider.isLoading, isFalse);
    });

    test('setRoleFilter triggert neuen Load mit Filter', () async {
      final fake = _FakeTeamService([
        _profile('a', 'a@x', role: 'admin'),
        _profile('b', 'b@x'),
      ]);
      final provider = TeamProvider(service: fake);

      await provider.setRoleFilter('admin');

      expect(fake.lastRoleFilter, 'admin');
      expect(provider.profiles.map((p) => p.id), ['a']);
    });

    test('setSearchQuery triggert neuen Load mit Query', () async {
      final fake = _FakeTeamService([
        _profile('a', 'alice@x'),
        _profile('b', 'bob@x'),
      ]);
      final provider = TeamProvider(service: fake);

      await provider.setSearchQuery('bob');

      expect(fake.lastSearchQuery, 'bob');
      expect(provider.profiles.map((p) => p.id), ['b']);
    });

    test('setUserRole tauscht das Profil und passt Counts an', () async {
      final fake = _FakeTeamService([
        _profile('a', 'a@x'),
        _profile('b', 'b@x'),
      ]);
      final provider = TeamProvider(service: fake);
      await provider.load();
      expect(provider.adminCount, 0);

      await provider.setUserRole(userId: 'a', newRole: 'admin');

      expect(provider.profiles.firstWhere((p) => p.id == 'a').role, 'admin');
      expect(provider.adminCount, 1);
      expect(provider.userCount, 1);
    });

    test('setUserRole setzt error und wirft Fehler weiter', () async {
      final fake = _FakeTeamService([_profile('a', 'a@x')]);
      fake.setRoleError = Exception('forbidden');
      final provider = TeamProvider(service: fake);
      await provider.load();

      await expectLater(
        provider.setUserRole(userId: 'a', newRole: 'admin'),
        throwsException,
      );
      expect(provider.error, contains('forbidden'));
    });

    test('clearError löscht den Fehlerzustand', () async {
      final fake = _FakeTeamService([]);
      fake.listError = Exception('boom');
      final provider = TeamProvider(service: fake);
      await provider.load();
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
