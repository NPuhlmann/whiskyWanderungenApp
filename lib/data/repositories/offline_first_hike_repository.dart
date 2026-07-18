import 'dart:developer';

import '../../domain/models/hike.dart';
import '../services/database/backend_api.dart';
import '../services/offline/offline_service.dart';
import '../services/connectivity/connectivity_service.dart';

/// Offline-First Repository für Hike-Daten
/// Implementiert das Offline-First-Pattern: Cache -> Network -> Error
class OfflineFirstHikeRepository {
  final BackendApiService _backendApiService;
  final OfflineService _offlineService;
  final ConnectivityService _connectivityService;

  OfflineFirstHikeRepository(
    this._backendApiService,
    this._offlineService,
    this._connectivityService,
  );

  // Katalog-Strategie ist per ADR-0008 fest auf networkFirst gesetzt; das
  // Enum bleibt intern, damit ein Strategiewechsel ein Ein-Zeilen-Edit bleibt.
  static const CacheStrategy _catalogStrategy = CacheStrategy.networkFirst;

  /// Alle verfügbaren Hikes abrufen (Offline-First)
  Future<List<Hike>> getAllAvailableHikes({bool forceRefresh = false}) async {
    try {
      switch (_catalogStrategy) {
        case CacheStrategy.cacheFirst:
          return await _getCacheFirstHikes(forceRefresh);
        case CacheStrategy.networkFirst:
          return await _getNetworkFirstHikes();
        case CacheStrategy.cacheOnly:
          return await _getCacheOnlyHikes();
        case CacheStrategy.networkOnly:
          return await _getNetworkOnlyHikes();
        case CacheStrategy.staleWhileRevalidate:
          return await _getStaleWhileRevalidateHikes();
      }
    } catch (e) {
      log("❌ Fehler beim Abrufen der Hikes: $e", error: e);
      rethrow;
    }
  }

  /// Benutzer-spezifische Hikes abrufen (Offline-First)
  Future<List<Hike>> getUserHikes(
    String userId, {
    bool forceRefresh = false,
  }) async {
    try {
      switch (_catalogStrategy) {
        case CacheStrategy.cacheFirst:
          return await _getCacheFirstUserHikes(userId, forceRefresh);
        case CacheStrategy.networkFirst:
          return await _getNetworkFirstUserHikes(userId);
        case CacheStrategy.cacheOnly:
          return await _getCacheOnlyUserHikes(userId);
        case CacheStrategy.networkOnly:
          return await _getNetworkOnlyUserHikes(userId);
        case CacheStrategy.staleWhileRevalidate:
          return await _getStaleWhileRevalidateUserHikes(userId);
      }
    } catch (e) {
      log("❌ Fehler beim Abrufen der Benutzer-Hikes: $e", error: e);
      rethrow;
    }
  }

  /// Cache-First-Strategien
  Future<List<Hike>> _getCacheFirstHikes(bool forceRefresh) async {
    // 1. Prüfe Cache falls nicht erzwungen neu geladen
    if (!forceRefresh) {
      final cachedHikes = await _offlineService.getCachedHikeList();
      if (cachedHikes != null && cachedHikes.isNotEmpty) {
        log("✅ Hikes aus Cache geladen (${cachedHikes.length} Items)");

        // Background-Update falls online
        if (_connectivityService.currentStatus.isConnected) {
          _updateHikesInBackground();
        }

        return cachedHikes;
      }
    }

    // 2. Falls Cache leer oder forceRefresh - versuche Online-Laden
    if (_connectivityService.currentStatus.isConnected) {
      try {
        final networkHikes = await _backendApiService.fetchHikes();

        // Cache aktualisieren
        await _offlineService.cacheHikeList(networkHikes);

        log(
          "✅ Hikes aus Netzwerk geladen und gecacht (${networkHikes.length} Items)",
        );
        return networkHikes;
      } catch (e) {
        log("⚠️ Netzwerk-Fehler beim Hikes-Laden: $e");

        // Fallback auf Cache auch bei Netzwerkfehler
        final cachedHikes = await _offlineService.getCachedHikeList();
        if (cachedHikes != null) {
          log("📦 Fallback auf gecachte Hikes (${cachedHikes.length} Items)");
          return cachedHikes;
        }

        rethrow;
      }
    }

    // 3. Offline und kein Cache - Fehler
    final cachedHikes = await _offlineService.getCachedHikeList();
    if (cachedHikes != null) {
      return cachedHikes;
    }

    throw Exception('Keine Hikes verfügbar (offline und kein Cache)');
  }

  Future<List<Hike>> _getCacheFirstUserHikes(
    String userId,
    bool forceRefresh,
  ) async {
    final listKey = 'user_$userId';

    // 1. Cache prüfen
    if (!forceRefresh) {
      final cachedHikes = await _offlineService.getCachedHikeList(
        listKey: listKey,
      );
      if (cachedHikes != null && cachedHikes.isNotEmpty) {
        log("✅ Benutzer-Hikes aus Cache geladen (${cachedHikes.length} Items)");

        // Background-Update falls online
        if (_connectivityService.currentStatus.isConnected) {
          _updateUserHikesInBackground(userId);
        }

        return cachedHikes;
      }
    }

    // 2. Online laden
    if (_connectivityService.currentStatus.isConnected) {
      try {
        final networkHikes = await _backendApiService.fetchUserHikes(userId);

        // Cache aktualisieren
        await _offlineService.cacheHikeList(networkHikes, listKey: listKey);

        log(
          "✅ Benutzer-Hikes aus Netzwerk geladen und gecacht (${networkHikes.length} Items)",
        );
        return networkHikes;
      } catch (e) {
        log("⚠️ Netzwerk-Fehler beim Benutzer-Hikes-Laden: $e");

        // Fallback auf Cache
        final cachedHikes = await _offlineService.getCachedHikeList(
          listKey: listKey,
        );
        if (cachedHikes != null) {
          log(
            "📦 Fallback auf gecachte Benutzer-Hikes (${cachedHikes.length} Items)",
          );
          return cachedHikes;
        }

        rethrow;
      }
    }

    // 3. Offline Fallback
    final cachedHikes = await _offlineService.getCachedHikeList(
      listKey: listKey,
    );
    if (cachedHikes != null) {
      return cachedHikes;
    }

    throw Exception('Keine Benutzer-Hikes verfügbar (offline und kein Cache)');
  }

  /// Network-First-Strategien
  Future<List<Hike>> _getNetworkFirstHikes() async {
    if (_connectivityService.currentStatus.isConnected) {
      try {
        final networkHikes = await _backendApiService.fetchHikes();
        await _offlineService.cacheHikeList(networkHikes);
        log("✅ Hikes aus Netzwerk geladen (Network-First)");
        return networkHikes;
      } catch (e) {
        log("⚠️ Network-First fehlgeschlagen, Fallback auf Cache: $e");
      }
    }

    // Fallback auf Cache
    final cachedHikes = await _offlineService.getCachedHikeList();
    if (cachedHikes != null) {
      return cachedHikes;
    }

    throw Exception('Keine Hikes verfügbar (Network-First gescheitert)');
  }

  Future<List<Hike>> _getNetworkFirstUserHikes(String userId) async {
    if (_connectivityService.currentStatus.isConnected) {
      try {
        final networkHikes = await _backendApiService.fetchUserHikes(userId);
        await _offlineService.cacheHikeList(
          networkHikes,
          listKey: 'user_$userId',
        );
        log("✅ Benutzer-Hikes aus Netzwerk geladen (Network-First)");
        return networkHikes;
      } catch (e) {
        log("⚠️ Network-First fehlgeschlagen, Fallback auf Cache: $e");
      }
    }

    // Fallback auf Cache
    final cachedHikes = await _offlineService.getCachedHikeList(
      listKey: 'user_$userId',
    );
    if (cachedHikes != null) {
      return cachedHikes;
    }

    throw Exception(
      'Keine Benutzer-Hikes verfügbar (Network-First gescheitert)',
    );
  }

  /// Cache-Only-Strategien
  Future<List<Hike>> _getCacheOnlyHikes() async {
    final cachedHikes = await _offlineService.getCachedHikeList();
    if (cachedHikes != null) {
      return cachedHikes;
    }
    throw Exception('Keine gecachten Hikes verfügbar');
  }

  Future<List<Hike>> _getCacheOnlyUserHikes(String userId) async {
    final cachedHikes = await _offlineService.getCachedHikeList(
      listKey: 'user_$userId',
    );
    if (cachedHikes != null) {
      return cachedHikes;
    }
    throw Exception('Keine gecachten Benutzer-Hikes verfügbar');
  }

  /// Network-Only-Strategien
  Future<List<Hike>> _getNetworkOnlyHikes() async {
    if (!_connectivityService.currentStatus.isConnected) {
      throw Exception('Keine Netzwerkverbindung für Network-Only-Strategie');
    }

    final networkHikes = await _backendApiService.fetchHikes();
    await _offlineService.cacheHikeList(networkHikes);
    return networkHikes;
  }

  Future<List<Hike>> _getNetworkOnlyUserHikes(String userId) async {
    if (!_connectivityService.currentStatus.isConnected) {
      throw Exception('Keine Netzwerkverbindung für Network-Only-Strategie');
    }

    final networkHikes = await _backendApiService.fetchUserHikes(userId);
    await _offlineService.cacheHikeList(networkHikes, listKey: 'user_$userId');
    return networkHikes;
  }

  /// Stale-While-Revalidate-Strategien
  Future<List<Hike>> _getStaleWhileRevalidateHikes() async {
    // 1. Sofort gecachte Daten zurückgeben
    final cachedHikes = await _offlineService.getCachedHikeList();

    // 2. Background-Update starten
    if (_connectivityService.currentStatus.isConnected) {
      _updateHikesInBackground();
    }

    // 3. Cache oder Exception
    if (cachedHikes != null) {
      return cachedHikes;
    }

    // Falls kein Cache, fallback zu Cache-First
    return await _getCacheFirstHikes(false);
  }

  Future<List<Hike>> _getStaleWhileRevalidateUserHikes(String userId) async {
    final cachedHikes = await _offlineService.getCachedHikeList(
      listKey: 'user_$userId',
    );

    if (_connectivityService.currentStatus.isConnected) {
      _updateUserHikesInBackground(userId);
    }

    if (cachedHikes != null) {
      return cachedHikes;
    }

    return await _getCacheFirstUserHikes(userId, false);
  }

  /// Background-Update-Methoden (Fire-and-Forget)
  void _updateHikesInBackground() async {
    try {
      final networkHikes = await _backendApiService.fetchHikes();
      await _offlineService.cacheHikeList(networkHikes);
      log("🔄 Background-Update für Hikes abgeschlossen");
    } catch (e) {
      log("⚠️ Background-Update für Hikes fehlgeschlagen: $e");
    }
  }

  void _updateUserHikesInBackground(String userId) async {
    try {
      final networkHikes = await _backendApiService.fetchUserHikes(userId);
      await _offlineService.cacheHikeList(
        networkHikes,
        listKey: 'user_$userId',
      );
      log("🔄 Background-Update für Benutzer-Hikes abgeschlossen");
    } catch (e) {
      log("⚠️ Background-Update für Benutzer-Hikes fehlgeschlagen: $e");
    }
  }

  /// Cache-Management
  Future<void> clearHikeCache() async {
    await _offlineService.clearCache(type: 'hike');
    log("🧹 Hike-Cache geleert");
  }
}

/// Cache-Strategien für verschiedene Anwendungsfälle
enum CacheStrategy {
  /// Cache zuerst, dann Network als Fallback
  cacheFirst,

  /// Network zuerst, dann Cache als Fallback
  networkFirst,

  /// Nur aus Cache laden
  cacheOnly,

  /// Nur aus Network laden
  networkOnly,

  /// Cache sofort zurückgeben, Background-Update starten
  staleWhileRevalidate,
}
