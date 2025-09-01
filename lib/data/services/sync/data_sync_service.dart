import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/models/hike.dart';
import '../../../domain/models/waypoint.dart';
import '../offline/offline_service.dart';
import '../connectivity/connectivity_service.dart';
import '../database/backend_api.dart';
import '../../repositories/offline_first_hike_repository.dart';
import '../../repositories/offline_first_waypoint_repository.dart';

/// Service für automatische Background-Synchronisation von Offline-Daten
class DataSyncService {
  static DataSyncService? _instance;
  static DataSyncService get instance => _instance ??= DataSyncService._internal();
  DataSyncService._internal();

  final OfflineService _offlineService = OfflineService();
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  
  BackendApiService? _backendApiService;
  OfflineFirstHikeRepository? _hikeRepository;
  OfflineFirstWaypointRepository? _waypointRepository;

  // Sync-Konfiguration
  static const Duration _syncInterval = Duration(minutes: 15);
  static const Duration _retryDelay = Duration(seconds: 30);
  static const int _maxRetries = 3;
  static const String _syncQueueKey = 'sync_queue';
  static const String _lastSyncKey = 'last_sync_timestamp';

  Timer? _syncTimer;
  bool _isInitialized = false;
  bool _isSyncing = false;
  StreamSubscription<NetworkStatus>? _networkSubscription;
  
  final StreamController<SyncStatus> _syncStatusController = 
      StreamController<SyncStatus>.broadcast();

  /// Sync-Status Stream
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Service initialisieren
  Future<void> initialize({
    required BackendApiService backendApiService,
    required OfflineFirstHikeRepository hikeRepository,
    required OfflineFirstWaypointRepository waypointRepository,
  }) async {
    if (_isInitialized) return;

    try {
      _backendApiService = backendApiService;
      _hikeRepository = hikeRepository;
      _waypointRepository = waypointRepository;

      // Netzwerkstatus-Änderungen überwachen
      _networkSubscription = _connectivityService.networkStatusStream.listen(
        _onNetworkStatusChanged,
        onError: (error) => log("❌ Netzwerk-Stream Fehler in DataSyncService: $error"),
      );

      // Periodische Sync starten
      _startPeriodicSync();

      // Initiale Sync falls online
      if (_connectivityService.currentStatus.isConnected) {
        _scheduleSync(delay: const Duration(seconds: 5));
      }

      _isInitialized = true;
      log("🔄 DataSyncService initialisiert");

    } catch (e) {
      log("❌ Fehler bei DataSyncService-Initialisierung: $e", error: e);
      rethrow;
    }
  }

  /// Service beenden
  Future<void> dispose() async {
    _syncTimer?.cancel();
    await _networkSubscription?.cancel();
    await _syncStatusController.close();
    _isInitialized = false;
    log("🔒 DataSyncService beendet");
  }

  /// Sofortige Synchronisation starten
  Future<SyncResult> syncNow({bool force = false}) async {
    if (!_isInitialized) {
      throw Exception('DataSyncService nicht initialisiert');
    }

    if (_isSyncing && !force) {
      log("⚠️ Sync bereits aktiv, überspringe");
      return SyncResult.skipped;
    }

    return await _performSync();
  }

  /// Daten-Item zur Sync-Queue hinzufügen
  Future<void> queueForSync(SyncItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_syncQueueKey) ?? '[]';
      final queue = List<Map<String, dynamic>>.from(jsonDecode(queueJson));
      
      queue.add(item.toJson());
      
      await prefs.setString(_syncQueueKey, jsonEncode(queue));
      log("📥 Item zur Sync-Queue hinzugefügt: ${item.type}:${item.action}");

      // Sofort sync falls online
      if (_connectivityService.currentStatus.isConnected) {
        _scheduleSync(delay: const Duration(seconds: 1));
      }

    } catch (e) {
      log("❌ Fehler beim Hinzufügen zur Sync-Queue: $e", error: e);
    }
  }

  /// Sync-Queue abrufen
  Future<List<SyncItem>> getSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_syncQueueKey) ?? '[]';
      final queue = List<Map<String, dynamic>>.from(jsonDecode(queueJson));
      
      return queue.map((json) => SyncItem.fromJson(json)).toList();
    } catch (e) {
      log("❌ Fehler beim Abrufen der Sync-Queue: $e", error: e);
      return [];
    }
  }

  /// Sync-Queue leeren
  Future<void> clearSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_syncQueueKey);
      log("🧹 Sync-Queue geleert");
    } catch (e) {
      log("❌ Fehler beim Leeren der Sync-Queue: $e", error: e);
    }
  }

  /// Sync-Statistiken abrufen
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getInt(_lastSyncKey);
      final queueSize = (await getSyncQueue()).length;
      
      return {
        'lastSyncTimestamp': lastSync,
        'lastSyncTime': lastSync != null 
            ? DateTime.fromMillisecondsSinceEpoch(lastSync).toIso8601String()
            : null,
        'queueSize': queueSize,
        'isActive': _isSyncing,
        'isOnline': _connectivityService.currentStatus.isConnected,
        'networkStatus': _connectivityService.currentStatus.toString(),
      };
    } catch (e) {
      log("❌ Fehler beim Abrufen der Sync-Statistiken: $e", error: e);
      return {'error': e.toString()};
    }
  }

  /// Private Methoden

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      if (_connectivityService.currentStatus.isConnected) {
        _scheduleSync();
      }
    });
  }

  void _scheduleSync({Duration? delay}) {
    Timer(delay ?? Duration.zero, () async {
      await _performSync();
    });
  }

  void _onNetworkStatusChanged(NetworkStatus status) {
    log("📡 Netzwerkstatus geändert: $status");
    
    if (status.isConnected && !_isSyncing) {
      log("🌐 Online - starte Sync");
      _scheduleSync(delay: const Duration(seconds: 2));
    }
  }

  Future<SyncResult> _performSync() async {
    if (_isSyncing) return SyncResult.skipped;
    
    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);
    
    try {
      log("🔄 Starte Daten-Synchronisation");

      if (!_connectivityService.currentStatus.isConnected) {
        log("⚠️ Sync übersprungen - offline");
        return SyncResult.offline;
      }

      final syncQueue = await getSyncQueue();
      if (syncQueue.isEmpty) {
        log("✅ Sync abgeschlossen - keine ausstehenden Items");
        await _updateLastSyncTimestamp();
        return SyncResult.success;
      }

      log("📊 Sync-Queue: ${syncQueue.length} Items");

      int successCount = 0;
      int failureCount = 0;
      final List<SyncItem> failedItems = [];

      // Sync-Items verarbeiten
      for (final item in syncQueue) {
        try {
          final success = await _processSyncItem(item);
          if (success) {
            successCount++;
            log("✅ Sync erfolgreich: ${item.type}:${item.action}");
          } else {
            failureCount++;
            failedItems.add(item);
            log("❌ Sync fehlgeschlagen: ${item.type}:${item.action}");
          }
        } catch (e) {
          failureCount++;
          failedItems.add(item);
          log("❌ Sync-Fehler für ${item.type}:${item.action}: $e");
        }
      }

      // Erfolgreich synchronisierte Items aus Queue entfernen
      await _updateSyncQueue(failedItems);
      await _updateLastSyncTimestamp();

      log("📊 Sync abgeschlossen - Erfolg: $successCount, Fehler: $failureCount");

      if (failureCount == 0) {
        _syncStatusController.add(SyncStatus.success);
        return SyncResult.success;
      } else if (successCount > 0) {
        _syncStatusController.add(SyncStatus.partialSuccess);
        return SyncResult.partialSuccess;
      } else {
        _syncStatusController.add(SyncStatus.error);
        return SyncResult.error;
      }

    } catch (e) {
      log("❌ Kritischer Sync-Fehler: $e", error: e);
      _syncStatusController.add(SyncStatus.error);
      return SyncResult.error;
    } finally {
      _isSyncing = false;
      _syncStatusController.add(SyncStatus.idle);
    }
  }

  Future<bool> _processSyncItem(SyncItem item) async {
    try {
      switch (item.type) {
        case 'waypoint':
          return await _processWaypointSync(item);
        case 'hike':
          return await _processHikeSync(item);
        default:
          log("⚠️ Unbekannter Sync-Item-Typ: ${item.type}");
          return false;
      }
    } catch (e) {
      log("❌ Fehler beim Verarbeiten des Sync-Items: $e", error: e);
      return false;
    }
  }

  Future<bool> _processWaypointSync(SyncItem item) async {
    try {
      switch (item.action) {
        case 'add':
          if (item.data != null && item.hikeId != null) {
            final waypoint = Waypoint.fromJson(item.data!);
            await _backendApiService!.addWaypoint(
              waypoint, 
              item.hikeId!,
              orderIndex: item.orderIndex,
            );
            return true;
          }
          break;

        case 'update':
          if (item.data != null) {
            final waypoint = Waypoint.fromJson(item.data!);
            await _backendApiService!.updateWaypoint(waypoint);
            return true;
          }
          break;

        case 'delete':
          if (item.waypointId != null && item.hikeId != null) {
            await _backendApiService!.deleteWaypoint(item.waypointId!, item.hikeId!);
            return true;
          }
          break;

        case 'reorder':
          if (item.waypointId != null && item.hikeId != null && item.orderIndex != null) {
            await _backendApiService!.updateWaypointOrder(
              item.hikeId!, 
              item.waypointId!, 
              item.orderIndex!,
            );
            return true;
          }
          break;
      }
      
      log("⚠️ Unvollständige Waypoint-Sync-Daten: ${item.action}");
      return false;

    } catch (e) {
      log("❌ Waypoint-Sync-Fehler: $e", error: e);
      return false;
    }
  }

  Future<bool> _processHikeSync(SyncItem item) async {
    try {
      // Vereinfacht - Hike-Sync ist normalerweise nur lesend
      log("ℹ️ Hike-Sync übersprungen (nur lesend): ${item.action}");
      return true;
    } catch (e) {
      log("❌ Hike-Sync-Fehler: $e", error: e);
      return false;
    }
  }

  Future<void> _updateSyncQueue(List<SyncItem> remainingItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(remainingItems.map((item) => item.toJson()).toList());
      await prefs.setString(_syncQueueKey, queueJson);
    } catch (e) {
      log("❌ Fehler beim Aktualisieren der Sync-Queue: $e", error: e);
    }
  }

  Future<void> _updateLastSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      log("❌ Fehler beim Aktualisieren des Sync-Timestamps: $e", error: e);
    }
  }
}

/// Sync-Item für die Queue
class SyncItem {
  final String type;
  final String action;
  final Map<String, dynamic>? data;
  final int? hikeId;
  final int? waypointId;
  final int? orderIndex;
  final DateTime timestamp;
  final int retryCount;

  SyncItem({
    required this.type,
    required this.action,
    this.data,
    this.hikeId,
    this.waypointId,
    this.orderIndex,
    DateTime? timestamp,
    this.retryCount = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'action': action,
      'data': data,
      'hikeId': hikeId,
      'waypointId': waypointId,
      'orderIndex': orderIndex,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory SyncItem.fromJson(Map<String, dynamic> json) {
    return SyncItem(
      type: json['type'],
      action: json['action'],
      data: json['data'],
      hikeId: json['hikeId'],
      waypointId: json['waypointId'],
      orderIndex: json['orderIndex'],
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
    );
  }

  SyncItem copyWithRetry() {
    return SyncItem(
      type: type,
      action: action,
      data: data,
      hikeId: hikeId,
      waypointId: waypointId,
      orderIndex: orderIndex,
      timestamp: timestamp,
      retryCount: retryCount + 1,
    );
  }

  @override
  String toString() {
    return 'SyncItem(type: $type, action: $action, hikeId: $hikeId, waypointId: $waypointId)';
  }
}

/// Sync-Status-Enumeration
enum SyncStatus {
  idle,
  syncing,
  success,
  partialSuccess,
  error,
}

/// Sync-Result-Enumeration
enum SyncResult {
  success,
  partialSuccess,
  error,
  offline,
  skipped,
}

/// Erweiterungen für bessere Lesbarkeit
extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.idle:
        return 'Bereit';
      case SyncStatus.syncing:
        return 'Synchronisiert...';
      case SyncStatus.success:
        return 'Erfolgreich';
      case SyncStatus.partialSuccess:
        return 'Teilweise erfolgreich';
      case SyncStatus.error:
        return 'Fehler';
    }
  }

  bool get isActive {
    return this == SyncStatus.syncing;
  }
}

extension SyncResultExtension on SyncResult {
  String get displayName {
    switch (this) {
      case SyncResult.success:
        return 'Erfolgreich synchronisiert';
      case SyncResult.partialSuccess:
        return 'Teilweise synchronisiert';
      case SyncResult.error:
        return 'Synchronisation fehlgeschlagen';
      case SyncResult.offline:
        return 'Offline - Sync übersprungen';
      case SyncResult.skipped:
        return 'Sync bereits aktiv';
    }
  }

  bool get isSuccess {
    return this == SyncResult.success;
  }
}