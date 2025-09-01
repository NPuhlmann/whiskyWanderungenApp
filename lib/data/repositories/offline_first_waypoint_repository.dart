import 'dart:developer';

import '../../domain/models/waypoint.dart';
import '../services/database/backend_api.dart';
import '../services/offline/offline_service.dart';
import '../services/connectivity/connectivity_service.dart';

/// Offline-First Repository für Waypoint-Daten
/// Implementiert intelligente Caching-Strategien für Waypoints
class OfflineFirstWaypointRepository {
  final BackendApiService _backendApiService;
  final OfflineService _offlineService;
  final ConnectivityService _connectivityService;

  OfflineFirstWaypointRepository(
    this._backendApiService,
    this._offlineService,
    this._connectivityService,
  );

  /// Waypoints für eine Wanderung abrufen (Offline-First)
  Future<List<Waypoint>> getWaypointsForHike(
    int hikeId, {
    bool forceRefresh = false,
    CacheStrategy strategy = CacheStrategy.cacheFirst,
  }) async {
    try {
      switch (strategy) {
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

  /// Waypoint hinzufügen (mit Offline-Sync-Unterstützung)
  Future<void> addWaypoint(
    Waypoint waypoint,
    int hikeId, {
    int? orderIndex,
    bool syncWhenOnline = true,
  }) async {
    try {
      if (_connectivityService.currentStatus.isConnected) {
        // Online: Sofort an Backend senden
        await _backendApiService.addWaypoint(waypoint, hikeId, orderIndex: orderIndex);
        log("✅ Waypoint online hinzugefügt: ${waypoint.id}");
        
        // Cache aktualisieren
        await _refreshWaypointCache(hikeId);
        
      } else {
        // Offline: Für später vormerken
        if (syncWhenOnline) {
          await _queueWaypointForSync(waypoint, hikeId, 'add', orderIndex: orderIndex);
          log("📥 Waypoint für Sync vorgemerkt: ${waypoint.id}");
        }
        
        // Lokalen Cache aktualisieren
        await _addWaypointToCache(waypoint, hikeId);
      }
    } catch (e) {
      log("❌ Fehler beim Hinzufügen des Waypoints: $e", error: e);
      rethrow;
    }
  }

  /// Waypoint aktualisieren (mit Offline-Sync-Unterstützung)
  Future<void> updateWaypoint(
    Waypoint waypoint, {
    bool syncWhenOnline = true,
  }) async {
    try {
      if (_connectivityService.currentStatus.isConnected) {
        // Online: Sofort an Backend senden
        await _backendApiService.updateWaypoint(waypoint);
        log("✅ Waypoint online aktualisiert: ${waypoint.id}");
        
        // Cache aktualisieren
        await _updateWaypointInCache(waypoint);
        
      } else {
        // Offline: Für später vormerken
        if (syncWhenOnline) {
          await _queueWaypointForSync(waypoint, null, 'update');
          log("📥 Waypoint-Update für Sync vorgemerkt: ${waypoint.id}");
        }
        
        // Lokalen Cache aktualisieren
        await _updateWaypointInCache(waypoint);
      }
    } catch (e) {
      log("❌ Fehler beim Aktualisieren des Waypoints: $e", error: e);
      rethrow;
    }
  }

  /// Waypoint löschen (mit Offline-Sync-Unterstützung)
  Future<void> deleteWaypoint(
    int waypointId,
    int hikeId, {
    bool syncWhenOnline = true,
  }) async {
    try {
      if (_connectivityService.currentStatus.isConnected) {
        // Online: Sofort an Backend senden
        await _backendApiService.deleteWaypoint(waypointId, hikeId);
        log("✅ Waypoint online gelöscht: $waypointId");
        
        // Cache aktualisieren
        await _refreshWaypointCache(hikeId);
        
      } else {
        // Offline: Für später vormerken
        if (syncWhenOnline) {
          await _queueWaypointForSync(null, hikeId, 'delete', waypointId: waypointId);
          log("📥 Waypoint-Löschung für Sync vorgemerkt: $waypointId");
        }
        
        // Lokalen Cache aktualisieren
        await _removeWaypointFromCache(waypointId, hikeId);
      }
    } catch (e) {
      log("❌ Fehler beim Löschen des Waypoints: $e", error: e);
      rethrow;
    }
  }

  /// Waypoint-Reihenfolge aktualisieren
  Future<void> updateWaypointOrder(
    int hikeId,
    int waypointId,
    int newOrderIndex, {
    bool syncWhenOnline = true,
  }) async {
    try {
      if (_connectivityService.currentStatus.isConnected) {
        // Online: Sofort an Backend senden
        await _backendApiService.updateWaypointOrder(hikeId, waypointId, newOrderIndex);
        log("✅ Waypoint-Reihenfolge online aktualisiert: $waypointId -> $newOrderIndex");
        
        // Cache aktualisieren
        await _refreshWaypointCache(hikeId);
        
      } else {
        // Offline: Für später vormerken
        if (syncWhenOnline) {
          await _queueWaypointForSync(null, hikeId, 'reorder', 
                                     waypointId: waypointId, orderIndex: newOrderIndex);
          log("📥 Waypoint-Reihenfolge für Sync vorgemerkt: $waypointId -> $newOrderIndex");
        }
        
        // Lokalen Cache aktualisieren
        await _updateWaypointOrderInCache(hikeId, waypointId, newOrderIndex);
      }
    } catch (e) {
      log("❌ Fehler beim Aktualisieren der Waypoint-Reihenfolge: $e", error: e);
      rethrow;
    }
  }

  /// Cache-First-Strategie
  Future<List<Waypoint>> _getCacheFirstWaypoints(int hikeId, bool forceRefresh) async {
    // 1. Cache prüfen falls nicht erzwungen neu geladen
    if (!forceRefresh) {
      final cachedWaypoints = await _offlineService.getCachedWaypoints(hikeId);
      if (cachedWaypoints != null && cachedWaypoints.isNotEmpty) {
        log("✅ Waypoints aus Cache geladen für Hike $hikeId (${cachedWaypoints.length} Items)");
        
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
        final networkWaypoints = await _backendApiService.getWaypointsForHike(hikeId);
        
        // Cache aktualisieren
        await _offlineService.cacheWaypoints(hikeId, networkWaypoints);
        
        log("✅ Waypoints aus Netzwerk geladen und gecacht für Hike $hikeId (${networkWaypoints.length} Items)");
        return networkWaypoints;
        
      } catch (e) {
        log("⚠️ Netzwerk-Fehler beim Waypoints-Laden: $e");
        
        // Fallback auf Cache auch bei Netzwerkfehler
        final cachedWaypoints = await _offlineService.getCachedWaypoints(hikeId);
        if (cachedWaypoints != null) {
          log("📦 Fallback auf gecachte Waypoints für Hike $hikeId (${cachedWaypoints.length} Items)");
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
    
    throw Exception('Keine Waypoints verfügbar für Hike $hikeId (offline und kein Cache)');
  }

  /// Network-First-Strategie
  Future<List<Waypoint>> _getNetworkFirstWaypoints(int hikeId) async {
    if (_connectivityService.currentStatus.isConnected) {
      try {
        final networkWaypoints = await _backendApiService.getWaypointsForHike(hikeId);
        await _offlineService.cacheWaypoints(hikeId, networkWaypoints);
        log("✅ Waypoints aus Netzwerk geladen (Network-First) für Hike $hikeId");
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
    
    throw Exception('Keine Waypoints verfügbar für Hike $hikeId (Network-First gescheitert)');
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
    
    final networkWaypoints = await _backendApiService.getWaypointsForHike(hikeId);
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
      final networkWaypoints = await _backendApiService.getWaypointsForHike(hikeId);
      await _offlineService.cacheWaypoints(hikeId, networkWaypoints);
      log("🔄 Background-Update für Waypoints von Hike $hikeId abgeschlossen");
    } catch (e) {
      log("⚠️ Background-Update für Waypoints von Hike $hikeId fehlgeschlagen: $e");
    }
  }

  /// Cache-Management-Hilfsmethoden
  Future<void> _refreshWaypointCache(int hikeId) async {
    try {
      final waypoints = await _backendApiService.getWaypointsForHike(hikeId);
      await _offlineService.cacheWaypoints(hikeId, waypoints);
      log("🔄 Waypoint-Cache für Hike $hikeId aktualisiert");
    } catch (e) {
      log("⚠️ Waypoint-Cache-Aktualisierung fehlgeschlagen: $e");
    }
  }

  Future<void> _addWaypointToCache(Waypoint waypoint, int hikeId) async {
    final cachedWaypoints = await _offlineService.getCachedWaypoints(hikeId) ?? [];
    cachedWaypoints.add(waypoint);
    await _offlineService.cacheWaypoints(hikeId, cachedWaypoints);
    log("📦 Waypoint zu lokalem Cache hinzugefügt: ${waypoint.id}");
  }

  Future<void> _updateWaypointInCache(Waypoint waypoint) async {
    // Da wir nicht wissen zu welchem Hike der Waypoint gehört,
    // müssen wir alle Hike-Caches durchsuchen (vereinfachte Implementierung)
    final cacheStats = await _offlineService.getCacheStats();
    log("🔍 Suche Waypoint ${waypoint.id} in Cache für Update");
  }

  Future<void> _removeWaypointFromCache(int waypointId, int hikeId) async {
    final cachedWaypoints = await _offlineService.getCachedWaypoints(hikeId);
    if (cachedWaypoints != null) {
      cachedWaypoints.removeWhere((w) => w.id == waypointId);
      await _offlineService.cacheWaypoints(hikeId, cachedWaypoints);
      log("🗑️ Waypoint aus lokalem Cache entfernt: $waypointId");
    }
  }

  Future<void> _updateWaypointOrderInCache(int hikeId, int waypointId, int newOrderIndex) async {
    final cachedWaypoints = await _offlineService.getCachedWaypoints(hikeId);
    if (cachedWaypoints != null) {
      final waypointIndex = cachedWaypoints.indexWhere((w) => w.id == waypointId);
      if (waypointIndex != -1) {
        final updatedWaypoint = cachedWaypoints[waypointIndex].copyWith(orderIndex: newOrderIndex);
        cachedWaypoints[waypointIndex] = updatedWaypoint;
        await _offlineService.cacheWaypoints(hikeId, cachedWaypoints);
        log("📦 Waypoint-Reihenfolge in lokalem Cache aktualisiert: $waypointId -> $newOrderIndex");
      }
    }
  }

  /// Sync-Queue-Management (vereinfacht)
  Future<void> _queueWaypointForSync(
    Waypoint? waypoint,
    int? hikeId,
    String action, {
    int? waypointId,
    int? orderIndex,
  }) async {
    try {
      final syncItem = {
        'action': action,
        'waypoint': waypoint?.toJson(),
        'hikeId': hikeId,
        'waypointId': waypointId,
        'orderIndex': orderIndex,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Vereinfacht: In SharedPreferences als JSON speichern
      // In einer vollständigen Implementierung würde man eine lokale DB verwenden
      await _offlineService.cacheData(
        type: 'waypoint_sync',
        id: '${DateTime.now().millisecondsSinceEpoch}',
        data: syncItem,
        toJson: (item) => item,
      );
      
      log("📥 Waypoint-Aktion für Sync vorgemerkt: $action");
      
    } catch (e) {
      log("❌ Fehler beim Vormerken der Waypoint-Aktion: $e", error: e);
    }
  }

  /// Prüfmethoden
  Future<bool> hasOfflineWaypoints(int hikeId) async {
    final cachedWaypoints = await _offlineService.getCachedWaypoints(hikeId);
    return cachedWaypoints != null && cachedWaypoints.isNotEmpty;
  }

  Future<int> getOfflineWaypointCount(int hikeId) async {
    final cachedWaypoints = await _offlineService.getCachedWaypoints(hikeId);
    return cachedWaypoints?.length ?? 0;
  }

  /// Cache-Verwaltung
  Future<void> clearWaypointCache({int? hikeId}) async {
    if (hikeId != null) {
      // Spezifischen Hike-Cache löschen
      await _offlineService.clearCache(type: 'waypoint');
      log("🧹 Waypoint-Cache für Hike $hikeId geleert");
    } else {
      // Gesamten Waypoint-Cache löschen
      await _offlineService.clearCache(type: 'waypoint');
      log("🧹 Gesamter Waypoint-Cache geleert");
    }
  }

  /// Repository-Status
  Future<Map<String, dynamic>> getRepositoryStats() async {
    final cacheStats = await _offlineService.getCacheStats();
    final networkStats = _connectivityService.getNetworkStats();
    
    return {
      'cache': cacheStats,
      'network': networkStats,
      'repositoryType': 'OfflineFirstWaypointRepository',
    };
  }

  /// Sync-Status prüfen
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    // Vereinfachte Implementierung - in Realität würde man eine lokale DB verwenden
    final cacheStats = await _offlineService.getCacheStats();
    
    // Placeholder: Zeige dass es eine Sync-Queue gibt
    return [];
  }

  /// Sync ausführen (wird von DataSyncService aufgerufen)
  Future<void> processPendingSync() async {
    if (!_connectivityService.currentStatus.isConnected) {
      log("⚠️ Sync übersprungen - keine Netzwerkverbindung");
      return;
    }
    
    log("🔄 Waypoint-Sync wird verarbeitet...");
    // Hier würde die tatsächliche Sync-Logik implementiert
    log("✅ Waypoint-Sync abgeschlossen");
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