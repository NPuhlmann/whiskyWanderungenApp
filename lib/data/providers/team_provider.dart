import 'package:flutter/foundation.dart';

import '../../domain/models/account.dart';
import '../repositories/user_repository.dart';

/// State-Management für die Team-Verwaltung (`/admin/team`).
///
/// Lädt Accounts (E-Mail, Rolle) über [UserRepository.listAccounts]. Die
/// Team-Verwaltung ist konzeptuell eine Account-Liste, keine Profile-Liste
/// (siehe ADR-0009) — Filter/Suche laufen deshalb client-seitig über die
/// bereits geladene Liste statt über eine erneute DB-Query.
class TeamProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  TeamProvider({required UserRepository userRepository})
    : _userRepository = userRepository;

  List<Account> _allAccounts = const [];
  List<Account> _accounts = const [];
  bool _isLoading = false;
  String? _error;

  String? _roleFilter;
  String _searchQuery = '';

  List<Account> get profiles => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get roleFilter => _roleFilter;
  String get searchQuery => _searchQuery;

  int get adminCount => _allAccounts.where((a) => a.role == 'admin').length;
  int get userCount => _allAccounts.length - adminCount;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _allAccounts = await _userRepository.listAccounts();
      _applyFilters();
    } catch (e) {
      _error = 'Konnte Team-Mitglieder nicht laden: $e';
      _allAccounts = const [];
      _accounts = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    Iterable<Account> result = _allAccounts;
    if (_roleFilter != null && _roleFilter!.isNotEmpty) {
      result = result.where((a) => a.role == _roleFilter);
    }
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((a) => a.email.toLowerCase().contains(q));
    }
    _accounts = result.toList();
  }

  Future<void> setRoleFilter(String? role) async {
    if (_roleFilter == role) return;
    _roleFilter = role;
    _applyFilters();
    notifyListeners();
  }

  Future<void> setSearchQuery(String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Setzt die Rolle eines Users. Bei Erfolg wird der lokale Account ersetzt,
  /// damit die UI sofort den neuen Zustand zeigt. Wirft die ursprüngliche
  /// Exception erneut, damit der Aufrufer eine Fehler-Snackbar zeigen kann.
  Future<void> setUserRole({
    required String userId,
    required String newRole,
  }) async {
    try {
      final updated = await _userRepository.setUserRole(
        userId: userId,
        newRole: newRole,
      );
      final idx = _allAccounts.indexWhere((a) => a.id == userId);
      if (idx >= 0) {
        final next = List<Account>.from(_allAccounts);
        next[idx] = updated;
        _allAccounts = next;
        _applyFilters();
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
