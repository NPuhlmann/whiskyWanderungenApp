import 'dart:developer';

import '../../domain/models/waypoint.dart';
import '../services/database/backend_api.dart';
import '../services/offline/offline_service.dart';
import '../services/connectivity/connectivity_service.dart';

/// Offline-first repository for waypoint data.
///
/// The public surface is deliberately narrow: one read plus a cache reset.
/// Writes go through `RouteManagementService` (admin web), not through this
/// repository.
class OfflineFirstWaypointRepository {
  final BackendApiService _backendApiService;
  final OfflineService _offlineService;
  final ConnectivityService _connectivityService;

  OfflineFirstWaypointRepository(
    this._backendApiService,
    this._offlineService,
    this._connectivityService,
  );

  // Fixed to networkFirst, mirroring OfflineFirstHikeRepository; the enum
  // stays internal so switching strategy remains a one-line edit.
  static const CacheStrategy _waypointStrategy = CacheStrategy.networkFirst;

  /// Fetches the waypoints for a hike (offline-first).
  ///
  /// [forceRefresh] is only consulted by the cacheFirst strategy and has no
  /// effect under networkFirst, which queries the network first regardless.
  /// It is kept for symmetry with `OfflineFirstHikeRepository`.
  Future<List<Waypoint>> getWaypointsForHike(
    int hikeId, {
    bool forceRefresh = false,
  }) async {
    try {
      switch (_waypointStrategy) {
        case CacheStrategy.cacheFirst:
          return await _getCacheFirstWaypoints(hikeId, forceRefresh);
        case CacheStrategy.networkFirst:
          return await _getNetworkFirstWaypoints(hikeId);
        case CacheStrategy.cacheOnly:
          return await _getCacheOnlyWaypoints(hikeId);
        case CacheStrategy.networkOnly:
          return await _getNetworkOnlyWaypoints(hikeId);
        case CacheStrategy.staleWhileRevalidate:
          return await _getStaleWhileRevalidateWaypoints(hikeId);
      }
    } catch (e) {
      log("❌ Fehler beim Abrufen der Waypoints für Hike $hikeId: $e", error: e);
      rethrow;
    }
  }

  /// Clears the entire waypoint cache (for the offline coordinator).
  Future<void> clearWaypointCache() async {
    await _offlineService.clearCache(type: 'waypoint');
    log("🧹 Waypoint-Cache geleert");
  }

  /// Cache-First-Strategie
  Future<List<Waypoint>> _getCacheFirstWaypoints(
    int hikeId,
    bool forceRefresh,
  ) async {
    // 1. Cache prüfen falls nicht erzwungen neu geladen
    if (!forceRefresh) {
      final cachedWaypoints = await _offlineService.getCachedWaypoints(hikeId);
      if (cachedWaypoints != null && cachedWaypoints.isNotEmpty) {
        log(
          "✅ Waypoints aus Cache geladen für Hike $hikeId (${cachedWaypoints.length} Items)",
        );

        // Background-Update falls online
        if (_connectivityService.currentStatus.isConnected) {
          _updateWaypointsInBackground(hikeId);
        }

        return cachedWaypoints;
      }
    }

    // 2. Online laden falls verfügbar
    if (_connectivityService.currentStatus.isConnected) {
      try {
        final networkWaypoints = await _backendApiService.getWaypointsForHike(
          hikeId,
        );

        // Cache aktualisieren
        await _offlineService.cacheWaypoints(hikeId, networkWaypoints);

        log(
          "✅ Waypoints aus Netzwerk geladen und gecacht für Hike $hikeId (${networkWaypoints.length} Items)",
        );
        return networkWaypoints;
      } catch (e) {
        log("⚠️ Netzwerk-Fehler beim Waypoints-Laden: $e");

        // Fallback auf Cache auch bei Netzwerkfehler
        final cachedWaypoints = await _offlineService.getCachedWaypoints(
          hikeId,
        );
        if (cachedWaypoints != null) {
          log(
            "📦 Fallback auf gecachte Waypoints für Hike $hikeId (${cachedWaypoints.length} Items)",
          );
          return cachedWaypoints;
        }

        rethrow;
      }
    }

    // 3. Offline Fallback
    final cachedWaypoints = await _offlineService.getCachedWaypoints(hikeId);
    if (cachedWaypoints != null) {
      return cachedWaypoints;
    }

    throw Exception(
      'Keine Waypoints verfügbar für Hike $hikeId (offline und kein Cache)',
    );
  }

  /// Network-First-Strategie
  Future<List<Waypoint>> _getNetworkFirstWaypoints(int hikeId) async {
    if (_connectivityService.currentStatus.isConnected) {
      try {
        final networkWaypoints = await _backendApiService.getWaypointsForHike(
          hikeId,
        );
        await _offlineService.cacheWaypoints(hikeId, networkWaypoints);
        log(
          "✅ Waypoints aus Netzwerk geladen (Network-First) für Hike $hikeId",
        );
        return networkWaypoints;
      } catch (e) {
        log("⚠️ Network-First fehlgeschlagen, Fallback auf Cache: $e");
      }
    }

    // Fallback auf Cache
    final cachedWaypoints = await _offlineService.getCachedWaypoints(hikeId);
    if (cachedWaypoints != null) {
      return cachedWaypoints;
    }

    throw Exception(
      'Keine Waypoints verfügbar für Hike $hikeId (Network-First gescheitert)',
    );
  }

  /// Cache-Only-Strategie
  Future<List<Waypoint>> _getCacheOnlyWaypoints(int hikeId) async {
    final cachedWaypoints = await _offlineService.getCachedWaypoints(hikeId);
    if (cachedWaypoints != null) {
      return cachedWaypoints;
    }
    throw Exception('Keine gecachten Waypoints verfügbar für Hike $hikeId');
  }

  /// Network-Only-Strategie
  Future<List<Waypoint>> _getNetworkOnlyWaypoints(int hikeId) async {
    if (!_connectivityService.currentStatus.isConnected) {
      throw Exception('Keine Netzwerkverbindung für Network-Only-Strategie');
    }

    final networkWaypoints = await _backendApiService.getWaypointsForHike(
      hikeId,
    );
    await _offlineService.cacheWaypoints(hikeId, networkWaypoints);
    return networkWaypoints;
  }

  /// Stale-While-Revalidate-Strategie
  Future<List<Waypoint>> _getStaleWhileRevalidateWaypoints(int hikeId) async {
    // 1. Sofort gecachte Daten zurückgeben
    final cachedWaypoints = await _offlineService.getCachedWaypoints(hikeId);

    // 2. Background-Update starten
    if (_connectivityService.currentStatus.isConnected) {
      _updateWaypointsInBackground(hikeId);
    }

    // 3. Cache oder Fallback
    if (cachedWaypoints != null) {
      return cachedWaypoints;
    }

    return await _getCacheFirstWaypoints(hikeId, false);
  }

  /// Background-Update (Fire-and-Forget)
  void _updateWaypointsInBackground(int hikeId) async {
    try {
      final networkWaypoints = await _backendApiService.getWaypointsForHike(
        hikeId,
      );
      await _offlineService.cacheWaypoints(hikeId, networkWaypoints);
      log("🔄 Background-Update für Waypoints von Hike $hikeId abgeschlossen");
    } catch (e) {
      log(
        "⚠️ Background-Update für Waypoints von Hike $hikeId fehlgeschlagen: $e",
      );
    }
  }
}

/// Cache-Strategien (wiederverwendet)
enum CacheStrategy {
  cacheFirst,
  networkFirst,
  cacheOnly,
  networkOnly,
  staleWhileRevalidate,
}
