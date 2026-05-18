import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/profile.dart';

/// Service für die Verwaltung der User-Liste und Rollen (Phase 8).
///
/// Lesen läuft direkt gegen die `profiles`-Tabelle (Admins haben dafür eine
/// SELECT-Policy). Rollenänderungen gehen über die SECURITY-DEFINER-RPC
/// [`public.set_user_role`], die alle Berechtigungs- und Konsistenzprüfungen
/// in der DB durchführt.
class TeamManagementService {
  final SupabaseClient _client;

  TeamManagementService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Lädt alle Profile, optional gefiltert nach Rolle bzw. einem Suchstring,
  /// der auf E-Mail / Vor- / Nachname matched. [limit] schützt die UI vor
  /// Endlos-Listen — die Default-Schranke reicht für absehbare Team-Größen.
  Future<List<Profile>> listProfiles({
    String? roleFilter,
    String? searchQuery,
    int limit = 200,
  }) async {
    try {
      var query = _client
          .from('profiles')
          .select('id, first_name, last_name, email, role, date_of_birth');

      if (roleFilter != null && roleFilter.isNotEmpty) {
        query = query.eq('role', roleFilter);
      }

      final trimmed = searchQuery?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        final pattern = '%${_escapeLike(trimmed)}%';
        query = query.or(
          'email.ilike.$pattern,'
          'first_name.ilike.$pattern,'
          'last_name.ilike.$pattern',
        );
      }

      final response = await query.order('email').limit(limit);
      return (response as List<dynamic>)
          .map((row) => Profile.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('TeamManagementService.listProfiles failed: $e');
      rethrow;
    }
  }

  /// Setzt die Rolle für [userId] auf [newRole] (`'user'` | `'admin'`).
  /// Ruft die DB-RPC auf — Berechtigungs- und Self-Demotion-Checks laufen
  /// dort. Liefert das aktualisierte Profil zurück.
  Future<Profile> setUserRole({
    required String userId,
    required String newRole,
  }) async {
    try {
      final response = await _client.rpc(
        'set_user_role',
        params: {
          'target_user_id': userId,
          'new_role': newRole,
        },
      );
      if (response == null) {
        throw StateError(
          'set_user_role returned no row for user $userId',
        );
      }
      // Supabase liefert für Funktionen, die `RETURNS row` deklarieren, ein
      // Map<String, dynamic> zurück.
      return Profile.fromJson(Map<String, dynamic>.from(response as Map));
    } catch (e) {
      debugPrint('TeamManagementService.setUserRole failed: $e');
      rethrow;
    }
  }

  String _escapeLike(String input) =>
      input.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_');
}
