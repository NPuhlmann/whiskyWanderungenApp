import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/account.dart';
import '../services/auth/auth_service.dart';

class UserRepository extends ChangeNotifier {
  final AuthService _authService;

  bool isLoggedIn = false;

  UserRepository(this._authService);

  Future<void> signUserOut() async {
    try {
      await _authService.signOut();
    } finally {
      notifyListeners();
    }
  }

  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password, [
    Map<String, dynamic>? data,
  ]) async {
    try {
      return await _authService.signUpWithEmailPassword(email, password, data);
    } finally {
      notifyListeners();
    }
  }

  Future<AuthResponse> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _authService.signInWithEmailPassword(email, password);
    } finally {
      notifyListeners();
    }
  }

  /// Emails a magic link / OTP code. No session exists yet afterwards, so
  /// there is nothing for the router to react to — hence no notify.
  Future<void> sendMagicLink(String email) async {
    await _authService.sendMagicLink(email);
  }

  Future<AuthResponse> verifyMagicLinkCode(String email, String code) async {
    try {
      return await _authService.verifyMagicLinkCode(email, code);
    } finally {
      notifyListeners();
    }
  }

  /// Re-fires [notifyListeners] so the router redirect re-evaluates after an
  /// auth change that happened outside this repository — notably a magic-link
  /// deep link resolving into a session inside the Supabase SDK.
  void signalAuthChanged() => notifyListeners();

  bool isUserLoggedIn() {
    isLoggedIn = _authService.isUserLoggedIn();
    return isLoggedIn;
  }

  String? getUserId() {
    return _authService.getCurrentUserId();
  }

  // E-Mail-Adresse des aktuellen Benutzers abrufen
  String? getUserEmail() {
    return _authService.getCurrentUserEmail();
  }

  // E-Mail-Adresse des Benutzers aktualisieren
  Future<void> updateUserEmail(String newEmail) async {
    await _authService.updateUserEmail(newEmail);
    notifyListeners();
  }

  /// Lädt das [Account] (E-Mail, Rolle) des aktuell eingeloggten Benutzers.
  /// E-Mail kommt aus der Auth-Session, Rolle aus `profiles.role`. Existiert
  /// noch keine Profil-Zeile, ist die Rolle standardmäßig 'user'.
  Future<Account> getAccount() async {
    final String? userId = getUserId();
    if (userId == null) {
      throw Exception('Benutzer-ID konnte nicht ermittelt werden');
    }
    try {
      final String role = await _fetchRole(userId);
      return Account(id: userId, email: getUserEmail() ?? '', role: role);
    } catch (e) {
      log("Error getting account for user $userId: $e");
      rethrow;
    }
  }

  /// Lädt alle [Account]s (E-Mail, Rolle) für die Admin-Team-Verwaltung.
  /// [limit] schützt die UI vor Endlos-Listen, wie zuvor bei
  /// `TeamManagementService.listProfiles`.
  Future<List<Account>> listAccounts({int limit = 500}) async {
    try {
      final response = await _authService.client
          .from('profiles')
          .select('id, email, role')
          .order('email')
          .limit(limit);
      return (response as List<dynamic>)
          .map((row) => Account.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log("Error listing accounts: $e");
      rethrow;
    }
  }

  Future<String> _fetchRole(String userId) async {
    final response = await _authService.client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();
    return (response?['role'] as String?) ?? 'user';
  }
}
