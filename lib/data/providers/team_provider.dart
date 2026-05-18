import 'package:flutter/foundation.dart';

import '../../domain/models/profile.dart';
import '../services/team/team_management_service.dart';

/// State-Management für die Team-Verwaltung (`/admin/team`).
class TeamProvider extends ChangeNotifier {
  final TeamManagementService _service;

  TeamProvider({TeamManagementService? service})
      : _service = service ?? TeamManagementService();

  List<Profile> _profiles = const [];
  bool _isLoading = false;
  String? _error;

  String? _roleFilter;
  String _searchQuery = '';

  List<Profile> get profiles => _profiles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get roleFilter => _roleFilter;
  String get searchQuery => _searchQuery;

  int get adminCount =>
      _profiles.where((p) => p.role == 'admin').length;
  int get userCount => _profiles.length - adminCount;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profiles = await _service.listProfiles(
        roleFilter: _roleFilter,
        searchQuery: _searchQuery,
      );
    } catch (e) {
      _error = 'Konnte Team-Mitglieder nicht laden: $e';
      _profiles = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setRoleFilter(String? role) async {
    if (_roleFilter == role) return;
    _roleFilter = role;
    await load();
  }

  Future<void> setSearchQuery(String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
    await load();
  }

  /// Setzt die Rolle eines Users. Bei Erfolg wird das lokale Profil ersetzt,
  /// damit die UI sofort den neuen Zustand zeigt. Wirft die ursprüngliche
  /// Exception erneut, damit der Aufrufer eine Fehler-Snackbar zeigen kann.
  Future<void> setUserRole({
    required String userId,
    required String newRole,
  }) async {
    try {
      final updated = await _service.setUserRole(
        userId: userId,
        newRole: newRole,
      );
      final idx = _profiles.indexWhere((p) => p.id == userId);
      if (idx >= 0) {
        final next = List<Profile>.from(_profiles);
        next[idx] = updated;
        _profiles = next;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Rolle konnte nicht gesetzt werden: $e';
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
