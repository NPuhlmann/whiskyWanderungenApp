import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/account.dart';

/// Service für Rollenänderungen in der Team-Verwaltung (Phase 8).
///
/// Rollenänderungen gehen über die SECURITY-DEFINER-RPC
/// [`public.set_user_role`], die alle Berechtigungs- und Konsistenzprüfungen
/// in der DB durchführt. Das Laden der Liste läuft über
/// `UserRepository.listAccounts()` — die Team-Verwaltung ist konzeptuell
/// eine Account-Liste (siehe ADR-0009).
class TeamManagementService {
  final SupabaseClient _client;

  TeamManagementService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Setzt die Rolle für [userId] auf [newRole] (`'user'` | `'admin'`).
  /// Ruft die DB-RPC auf — Berechtigungs- und Self-Demotion-Checks laufen
  /// dort. Liefert den aktualisierten Account zurück.
  Future<Account> setUserRole({
    required String userId,
    required String newRole,
  }) async {
    try {
      final response = await _client.rpc(
        'set_user_role',
        params: {'target_user_id': userId, 'new_role': newRole},
      );
      if (response == null) {
        throw StateError('set_user_role returned no row for user $userId');
      }
      // Supabase liefert für Funktionen, die `RETURNS row` deklarieren, ein
      // Map<String, dynamic> zurück - Account.fromJson liest daraus nur
      // id/email/role, weitere Spalten werden ignoriert.
      return Account.fromJson(Map<String, dynamic>.from(response as Map));
    } catch (e) {
      debugPrint('TeamManagementService.setUserRole failed: $e');
      rethrow;
    }
  }
}
