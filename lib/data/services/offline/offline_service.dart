import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/models/hike.dart';
import '../../../domain/models/waypoint.dart';
import '../../../domain/models/tasting_set.dart';

/// Erweiterte Offline-Service-Klasse für generisches Caching verschiedener Datentypen
class OfflineService {
  static const String _keyPrefix = 'offline_cache';
  static const String _timestampSuffix = '_timestamp';
  static const String _metadataSuffix = '_metadata';
  
  // Cache-TTL-Konfiguration
  static const Duration defaultTtl = Duration(hours: 24);
  static const Duration hikeDataTtl = Duration(hours: 12);
  static const Duration waypointDataTtl = Duration(hours: 6);
  static const Duration orderDataTtl = Duration(hours: 48);
  static const Duration imageDataTtl = Duration(days: 7);
  
  // Cache-Größenverwaltung
  static const int maxCacheSizeBytes = 100 * 1024 * 1024; // 100MB
  static const int maxItemsPerType = 500;

  SharedPreferences? _prefs;
  String? _cacheDirectory;
  bool _disposed = false;

  Future<void> _initializePrefs() async {
    _checkNotDisposed();
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _initializeCacheDirectory() async {
    _checkNotDisposed();
    if (_cacheDirectory == null) {
      final directory = await getApplicationDocumentsDirectory();
      _cacheDirectory = '${directory.path}/offline_cache';
      
      final cacheDir = Directory(_cacheDirectory!);
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
        log("📁 Offline-Cache-Verzeichnis erstellt: $_cacheDirectory");
      }
    }
  }

  /// Generische Methode zum Cachen von Daten
  Future<void> cacheData<T>({
    required String type,
    required String id,
    required T data,
    required Map<String, dynamic> Function(T) toJson,
    Duration? ttl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _initializePrefs();
      
      final key = '${_keyPrefix}_${type}_$id';
      final timestampKey = '$key$_timestampSuffix';
      final metadataKey = '$key$_metadataSuffix';
      
      // Daten serialisieren
      final jsonData = toJson(data);
      final dataString = jsonEncode(jsonData);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // In SharedPreferences speichern
      await _prefs!.setString(key, dataString);
      await _prefs!.setInt(timestampKey, timestamp);
      
      if (metadata != null) {
        await _prefs!.setString(metadataKey, jsonEncode(metadata));
      }
      
      log("💾 Daten gecacht - Type: $type, ID: $id");
      
      // Cache-Größe verwalten
      await _manageCacheSizeForType(type);
      
    } catch (e) {
      log("❌ Fehler beim Cachen der Daten ($type:$id): $e", error: e);
    }
  }

  /// Generische Methode zum Laden gecachter Daten
  Future<T?> getCachedData<T>({
    required String type,
    required String id,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? ttl,
  }) async {
    try {
      await _initializePrefs();
      
      final key = '${_keyPrefix}_${type}_$id';
      final timestampKey = '$key$_timestampSuffix';
      
      final dataString = _prefs!.getString(key);
      final timestamp = _prefs!.getInt(timestampKey);
      
      if (dataString == null || timestamp == null) {
        return null;
      }
      
      // Cache-Gültigkeit prüfen
      final cacheTtl = ttl ?? _getTtlForType(type);
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final isExpired = DateTime.now().difference(cacheTime) > cacheTtl;
      
      if (isExpired) {
        log("⏰ Gecachte Daten sind abgelaufen - Type: $type, ID: $id");
        await _removeCachedItem(key);
        return null;
      }
      
      // Daten deserialisieren
      final jsonData = jsonDecode(dataString) as Map<String, dynamic>;
      final data = fromJson(jsonData);
      
      log("✅ Gecachte Daten geladen - Type: $type, ID: $id");
      return data;
      
    } catch (e) {
      log("❌ Fehler beim Laden gecachter Daten ($type:$id): $e", error: e);
      return null;
    }
  }

  /// Cache-Liste für einen Datentyp
  Future<void> cacheDataList<T>({
    required String type,
    required String listKey,
    required List<T> data,
    required Map<String, dynamic> Function(T) toJson,
    Duration? ttl,
  }) async {
    try {
      await _initializePrefs();
      
      final key = '${_keyPrefix}_${type}_list_$listKey';
      final timestampKey = '$key$_timestampSuffix';
      
      // Liste serialisieren
      final jsonList = data.map((item) => toJson(item)).toList();
      final dataString = jsonEncode(jsonList);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      await _prefs!.setString(key, dataString);
      await _prefs!.setInt(timestampKey, timestamp);
      
      log("💾 Datenliste gecacht - Type: $type, Key: $listKey, Count: ${data.length}");
      
    } catch (e) {
      log("❌ Fehler beim Cachen der Datenliste ($type:$listKey): $e", error: e);
    }
  }

  /// Cache-Liste laden
  Future<List<T>?> getCachedDataList<T>({
    required String type,
    required String listKey,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? ttl,
  }) async {
    try {
      await _initializePrefs();
      
      final key = '${_keyPrefix}_${type}_list_$listKey';
      final timestampKey = '$key$_timestampSuffix';
      
      final dataString = _prefs!.getString(key);
      final timestamp = _prefs!.getInt(timestampKey);
      
      if (dataString == null || timestamp == null) {
        return null;
      }
      
      // Cache-Gültigkeit prüfen
      final cacheTtl = ttl ?? _getTtlForType(type);
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final isExpired = DateTime.now().difference(cacheTime) > cacheTtl;
      
      if (isExpired) {
        log("⏰ Gecachte Datenliste ist abgelaufen - Type: $type, Key: $listKey");
        await _removeCachedItem(key);
        return null;
      }
      
      // Liste deserialisieren
      final jsonList = jsonDecode(dataString) as List<dynamic>;
      final data = jsonList
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
      
      log("✅ Gecachte Datenliste geladen - Type: $type, Key: $listKey, Count: ${data.length}");
      return data;
      
    } catch (e) {
      log("❌ Fehler beim Laden gecachter Datenliste ($type:$listKey): $e", error: e);
      return null;
    }
  }

  /// Spezifische Methoden für verschiedene Datentypen
  
  // Hike-spezifische Methoden
  Future<void> cacheHike(Hike hike) async {
    await cacheData<Hike>(
      type: 'hike',
      id: hike.id.toString(),
      data: hike,
      toJson: (h) => h.toJson(),
      ttl: hikeDataTtl,
    );
  }

  Future<Hike?> getCachedHike(int hikeId) async {
    return await getCachedData<Hike>(
      type: 'hike',
      id: hikeId.toString(),
      fromJson: (json) => Hike.fromJson(json),
      ttl: hikeDataTtl,
    );
  }

  Future<void> cacheHikeList(List<Hike> hikes, {String listKey = 'all'}) async {
    await cacheDataList<Hike>(
      type: 'hike',
      listKey: listKey,
      data: hikes,
      toJson: (h) => h.toJson(),
      ttl: hikeDataTtl,
    );
  }

  Future<List<Hike>?> getCachedHikeList({String listKey = 'all'}) async {
    return await getCachedDataList<Hike>(
      type: 'hike',
      listKey: listKey,
      fromJson: (json) => Hike.fromJson(json),
      ttl: hikeDataTtl,
    );
  }

  // Waypoint-spezifische Methoden
  Future<void> cacheWaypoints(int hikeId, List<Waypoint> waypoints) async {
    await cacheDataList<Waypoint>(
      type: 'waypoint',
      listKey: 'hike_$hikeId',
      data: waypoints,
      toJson: (w) => w.toJson(),
      ttl: waypointDataTtl,
    );
  }

  Future<List<Waypoint>?> getCachedWaypoints(int hikeId) async {
    return await getCachedDataList<Waypoint>(
      type: 'waypoint',
      listKey: 'hike_$hikeId',
      fromJson: (json) => Waypoint.fromJson(json),
      ttl: waypointDataTtl,
    );
  }

  // Tasting Set-spezifische Methoden
  Future<void> cacheTastingSet(TastingSet tastingSet) async {
    await cacheData<TastingSet>(
      type: 'tasting_set',
      id: tastingSet.hikeId.toString(),
      data: tastingSet,
      toJson: (ts) => ts.toJson(),
    );
  }

  Future<TastingSet?> getCachedTastingSet(int hikeId) async {
    return await getCachedData<TastingSet>(
      type: 'tasting_set',
      id: hikeId.toString(),
      fromJson: (json) => TastingSet.fromJson(json),
    );
  }

  /// Prüfmethoden
  Future<bool> hasCachedData(String type, String id, {Duration? ttl}) async {
    try {
      await _initializePrefs();
      
      final key = '${_keyPrefix}_${type}_$id';
      final timestampKey = '$key$_timestampSuffix';
      
      final timestamp = _prefs!.getInt(timestampKey);
      if (timestamp == null) return false;
      
      final cacheTtl = ttl ?? _getTtlForType(type);
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final isExpired = DateTime.now().difference(cacheTime) > cacheTtl;
      
      return !isExpired;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasCachedDataList(String type, String listKey, {Duration? ttl}) async {
    try {
      await _initializePrefs();
      
      final key = '${_keyPrefix}_${type}_list_$listKey';
      final timestampKey = '$key$_timestampSuffix';
      
      final timestamp = _prefs!.getInt(timestampKey);
      if (timestamp == null) return false;
      
      final cacheTtl = ttl ?? _getTtlForType(type);
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final isExpired = DateTime.now().difference(cacheTime) > cacheTtl;
      
      return !isExpired;
    } catch (e) {
      return false;
    }
  }

  /// Cache-Verwaltung
  Future<void> clearCache({String? type}) async {
    try {
      await _initializePrefs();
      
      final keys = _prefs!.getKeys();
      
      final keysToRemove = keys.where((key) {
        if (!key.startsWith(_keyPrefix)) return false;
        if (type == null) return true;
        return key.contains('${_keyPrefix}_${type}_');
      }).toList();
      
      for (final key in keysToRemove) {
        await _prefs!.remove(key);
      }
      
      log("🧹 Cache gelöscht - Type: ${type ?? 'all'}, Keys: ${keysToRemove.length}");
      
    } catch (e) {
      log("❌ Fehler beim Löschen des Cache: $e", error: e);
    }
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      await _initializePrefs();
      
      final keys = _prefs!.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith(_keyPrefix)).toList();
      
      final stats = <String, int>{};
      for (final key in cacheKeys) {
        if (key.endsWith(_timestampSuffix) || key.endsWith(_metadataSuffix)) continue;
        
        final parts = key.split('_');
        if (parts.length >= 3) {
          final type = parts[2];
          stats[type] = (stats[type] ?? 0) + 1;
        }
      }
      
      return {
        'totalCacheKeys': cacheKeys.length,
        'typeStats': stats,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
    } catch (e) {
      log("❌ Fehler beim Abrufen der Cache-Statistiken: $e", error: e);
      return {'error': e.toString()};
    }
  }

  /// Private Helper-Methoden
  Duration _getTtlForType(String type) {
    switch (type.toLowerCase()) {
      case 'hike':
        return hikeDataTtl;
      case 'waypoint':
        return waypointDataTtl;
      case 'order':
      case 'enhanced_order':
        return orderDataTtl;
      case 'image':
        return imageDataTtl;
      default:
        return defaultTtl;
    }
  }

  Future<void> _manageCacheSizeForType(String type) async {
    try {
      await _initializePrefs();
      
      final keys = _prefs!.getKeys();
      final typeKeys = keys
          .where((key) => key.startsWith('${_keyPrefix}_${type}_'))
          .where((key) => !key.endsWith(_timestampSuffix) && !key.endsWith(_metadataSuffix))
          .toList();
      
      if (typeKeys.length <= maxItemsPerType) return;
      
      // Sortiere nach Timestamp (älteste zuerst)
      typeKeys.sort((a, b) {
        final timestampA = _prefs!.getInt('$a$_timestampSuffix') ?? 0;
        final timestampB = _prefs!.getInt('$b$_timestampSuffix') ?? 0;
        return timestampA.compareTo(timestampB);
      });
      
      // Lösche älteste Items
      final itemsToRemove = typeKeys.length - maxItemsPerType;
      for (int i = 0; i < itemsToRemove; i++) {
        await _removeCachedItem(typeKeys[i]);
      }
      
      log("🗑️ Cache-Größe verwaltet - Type: $type, Entfernt: $itemsToRemove Items");
      
    } catch (e) {
      log("❌ Fehler bei Cache-Größenverwaltung für $type: $e", error: e);
    }
  }

  Future<void> _removeCachedItem(String key) async {
    try {
      await _prefs!.remove(key);
      await _prefs!.remove('$key$_timestampSuffix');
      await _prefs!.remove('$key$_metadataSuffix');
    } catch (e) {
      log("❌ Fehler beim Entfernen des Cache-Items $key: $e", error: e);
    }
  }

  /// Dispose method for explicit resource cleanup and memory leak prevention
  Future<void> dispose() async {
    if (_disposed) return;
    
    try {
      log("🧹 Disposing OfflineService resources...");
      
      // Clear any in-memory references
      _prefs = null;
      _cacheDirectory = null;
      
      // Mark as disposed to prevent further operations
      _disposed = true;
      
      log("✅ OfflineService disposed successfully");
      
    } catch (e) {
      log("❌ Error during OfflineService disposal: $e", error: e);
    }
  }

  /// Check if service has been disposed
  bool get isDisposed => _disposed;

  /// Internal method to check disposal state before operations
  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('OfflineService has been disposed and cannot be used');
    }
  }

  /// Periodic cache cleanup to prevent memory buildup
  Future<void> performMaintenanceCleanup() async {
    try {
      _checkNotDisposed();
      await _initializePrefs();
      
      log("🧹 Performing maintenance cache cleanup...");
      
      final keys = _prefs!.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith(_keyPrefix)).toList();
      
      int removedCount = 0;
      final now = DateTime.now();
      
      for (final key in cacheKeys) {
        if (key.endsWith(_timestampSuffix) || key.endsWith(_metadataSuffix)) continue;
        
        final timestampKey = '$key$_timestampSuffix';
        final timestamp = _prefs!.getInt(timestampKey);
        
        if (timestamp == null) {
          await _removeCachedItem(key);
          removedCount++;
          continue;
        }
        
        // Extract type from key to get appropriate TTL
        final parts = key.split('_');
        final type = parts.length >= 3 ? parts[2] : 'unknown';
        final ttl = _getTtlForType(type);
        
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final isExpired = now.difference(cacheTime) > ttl;
        
        if (isExpired) {
          await _removeCachedItem(key);
          removedCount++;
        }
      }
      
      log("✅ Maintenance cleanup completed - Removed $removedCount expired items");
      
    } catch (e) {
      log("❌ Error during maintenance cleanup: $e", error: e);
    }
  }

  /// Clean up cache directory files if they exist
  Future<void> cleanupCacheDirectory() async {
    try {
      _checkNotDisposed();
      await _initializeCacheDirectory();
      
      if (_cacheDirectory != null) {
        final cacheDir = Directory(_cacheDirectory!);
        if (await cacheDir.exists()) {
          log("🧹 Cleaning cache directory: $_cacheDirectory");
          await cacheDir.delete(recursive: true);
          log("✅ Cache directory cleaned successfully");
        }
      }
    } catch (e) {
      log("❌ Error cleaning cache directory: $e", error: e);
    }
  }
}