import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Service für erweiterte Netzwerkkonnektivitätsprüfungen
class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance =>
      _instance ??= ConnectivityService._internal();
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<InternetStatus>? _internetSubscription;

  final StreamController<NetworkStatus> _networkStatusController =
      StreamController<NetworkStatus>.broadcast();

  NetworkStatus _currentStatus = NetworkStatus.unknown;
  DateTime? _lastConnectedTime;
  DateTime? _lastDisconnectedTime;

  /// Aktueller Netzwerkstatus
  NetworkStatus get currentStatus => _currentStatus;

  /// Stream für Netzwerkstatus-Änderungen
  Stream<NetworkStatus> get networkStatusStream =>
      _networkStatusController.stream;

  /// Letzte Verbindungszeit
  DateTime? get lastConnectedTime => _lastConnectedTime;

  /// Letzte Trennungszeit
  DateTime? get lastDisconnectedTime => _lastDisconnectedTime;

  /// Service initialisieren und Überwachung starten
  Future<void> initialize() async {
    try {
      // Initialen Status ermitteln
      _currentStatus = await checkNetworkStatus();

      // Connectivity-Changes überwachen
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) =>
            log("❌ Connectivity-Stream Fehler: $error", error: error),
      );

      // Internet-Verbindung überwachen
      _internetSubscription = _internetChecker.onStatusChange.listen(
        _onInternetStatusChanged,
        onError: (error) =>
            log("❌ Internet-Status-Stream Fehler: $error", error: error),
      );

      log("📡 ConnectivityService initialisiert - Status: $_currentStatus");
    } catch (e) {
      log("❌ Fehler bei ConnectivityService-Initialisierung: $e", error: e);
      _currentStatus = NetworkStatus.unknown;
    }
  }

  /// Service beenden und Streams schließen
  Future<void> dispose() async {
    try {
      await _connectivitySubscription?.cancel();
      _connectivitySubscription = null;

      await _internetSubscription?.cancel();
      _internetSubscription = null;

      if (!_networkStatusController.isClosed) {
        await _networkStatusController.close();
      }

      log("🔒 ConnectivityService beendet");
    } catch (e) {
      log("⚠️ Fehler beim ConnectivityService dispose: $e", error: e);
      // Don't rethrow - this is cleanup code
    }
  }

  /// Aktuellen Netzwerkstatus prüfen
  Future<NetworkStatus> checkNetworkStatus() async {
    try {
      // 1. Connectivity prüfen
      final connectivityResults = await _connectivity.checkConnectivity();

      if (connectivityResults.contains(ConnectivityResult.none)) {
        return NetworkStatus.disconnected;
      }

      // 2. Tatsächliche Internet-Verbindung prüfen
      final hasInternet = await _internetChecker.hasInternetAccess;

      if (!hasInternet) {
        return NetworkStatus.connectedNoInternet;
      }

      // 3. Verbindungsqualität ermitteln
      final connectionType = _getConnectionType(connectivityResults);
      final quality = await _checkConnectionQuality();

      switch (quality) {
        case ConnectionQuality.good:
          return connectionType == ConnectionType.wifi
              ? NetworkStatus.connectedWifiGood
              : NetworkStatus.connectedMobileGood;
        case ConnectionQuality.poor:
          return connectionType == ConnectionType.wifi
              ? NetworkStatus.connectedWifiPoor
              : NetworkStatus.connectedMobilePoor;
        case ConnectionQuality.unknown:
          return connectionType == ConnectionType.wifi
              ? NetworkStatus.connectedWifi
              : NetworkStatus.connectedMobile;
      }
    } catch (e) {
      log("❌ Fehler bei Netzwerkstatus-Prüfung: $e", error: e);
      return NetworkStatus.unknown;
    }
  }

  /// Prüfe ob Internet-Verbindung verfügbar ist
  Future<bool> hasInternetConnection() async {
    try {
      return await _internetChecker.hasInternetAccess;
    } catch (e) {
      log("❌ Fehler bei Internet-Verbindungsprüfung: $e", error: e);
      return false;
    }
  }

  /// Prüfe spezifische Host-Erreichbarkeit
  Future<bool> canReachHost(String host) async {
    try {
      final result = await InternetAddress.lookup(host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      log("❌ Host $host nicht erreichbar: $e", error: e);
      return false;
    }
  }

  /// Prüfe Supabase-Erreichbarkeit
  Future<bool> canReachSupabase() async {
    // Supabase verwendet verschiedene Domains, prüfe die wichtigsten
    final hosts = ['supabase.co', 'supabase.io', 'postgrest.org'];

    for (final host in hosts) {
      if (await canReachHost(host)) {
        return true;
      }
    }

    return false;
  }

  /// Verbindungsqualität messen
  Future<ConnectionQuality> _checkConnectionQuality() async {
    try {
      final stopwatch = Stopwatch()..start();

      // Einfacher Ping-Test zu einem schnellen Server
      final result = await InternetAddress.lookup('1.1.1.1');
      stopwatch.stop();

      if (result.isEmpty) {
        return ConnectionQuality.unknown;
      }

      final latency = stopwatch.elapsedMilliseconds;

      if (latency < 100) {
        return ConnectionQuality.good;
      } else if (latency < 500) {
        return ConnectionQuality.poor;
      } else {
        return ConnectionQuality.poor;
      }
    } catch (e) {
      log("❌ Fehler bei Verbindungsqualitäts-Messung: $e", error: e);
      return ConnectionQuality.unknown;
    }
  }

  /// Event-Handler für Connectivity-Änderungen
  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    try {
      final newStatus = await checkNetworkStatus();
      _updateNetworkStatus(newStatus);
    } catch (e) {
      log("❌ Fehler bei Connectivity-Change-Behandlung: $e", error: e);
    }
  }

  /// Event-Handler für Internet-Status-Änderungen
  void _onInternetStatusChanged(InternetStatus status) async {
    try {
      final newNetworkStatus = await checkNetworkStatus();
      _updateNetworkStatus(newNetworkStatus);
    } catch (e) {
      log("❌ Fehler bei Internet-Status-Change-Behandlung: $e", error: e);
    }
  }

  /// Netzwerkstatus aktualisieren und Event senden
  void _updateNetworkStatus(NetworkStatus newStatus) {
    if (_currentStatus != newStatus) {
      final oldStatus = _currentStatus;
      _currentStatus = newStatus;

      // Zeitstempel aktualisieren
      if (_isConnected(newStatus) && !_isConnected(oldStatus)) {
        _lastConnectedTime = DateTime.now();
        log("🟢 Netzwerkverbindung wiederhergestellt: $newStatus");
      } else if (!_isConnected(newStatus) && _isConnected(oldStatus)) {
        _lastDisconnectedTime = DateTime.now();
        log("🔴 Netzwerkverbindung verloren: $newStatus");
      }

      // Status-Änderung broadcasten
      _networkStatusController.add(_currentStatus);
      log("📡 Netzwerkstatus geändert: $oldStatus -> $newStatus");
    }
  }

  /// Hilfsmethoden
  bool _isConnected(NetworkStatus status) {
    return status != NetworkStatus.disconnected &&
        status != NetworkStatus.connectedNoInternet &&
        status != NetworkStatus.unknown;
  }

  ConnectionType _getConnectionType(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectionType.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      return ConnectionType.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectionType.ethernet;
    }
    return ConnectionType.other;
  }

  /// Netzwerkstatistiken abrufen
  Map<String, dynamic> getNetworkStats() {
    return {
      'currentStatus': _currentStatus.toString(),
      'lastConnectedTime': _lastConnectedTime?.toIso8601String(),
      'lastDisconnectedTime': _lastDisconnectedTime?.toIso8601String(),
      'isConnected': _isConnected(_currentStatus),
      'uptime': _lastConnectedTime != null
          ? DateTime.now().difference(_lastConnectedTime!).inSeconds
          : null,
      'downtime': _lastDisconnectedTime != null
          ? DateTime.now().difference(_lastDisconnectedTime!).inSeconds
          : null,
    };
  }
}

/// Netzwerkstatus-Enumeration
enum NetworkStatus {
  unknown,
  disconnected,
  connectedNoInternet,
  connectedWifi,
  connectedWifiGood,
  connectedWifiPoor,
  connectedMobile,
  connectedMobileGood,
  connectedMobilePoor,
  connectedEthernet,
}

/// Verbindungstyp-Enumeration
enum ConnectionType { wifi, mobile, ethernet, other }

/// Verbindungsqualität-Enumeration
enum ConnectionQuality { unknown, poor, good }

/// Erweiterungen für bessere Lesbarkeit
extension NetworkStatusExtension on NetworkStatus {
  bool get isConnected {
    switch (this) {
      case NetworkStatus.connectedWifi:
      case NetworkStatus.connectedWifiGood:
      case NetworkStatus.connectedWifiPoor:
      case NetworkStatus.connectedMobile:
      case NetworkStatus.connectedMobileGood:
      case NetworkStatus.connectedMobilePoor:
      case NetworkStatus.connectedEthernet:
        return true;
      default:
        return false;
    }
  }

  bool get isWifi {
    switch (this) {
      case NetworkStatus.connectedWifi:
      case NetworkStatus.connectedWifiGood:
      case NetworkStatus.connectedWifiPoor:
        return true;
      default:
        return false;
    }
  }

  bool get isMobile {
    switch (this) {
      case NetworkStatus.connectedMobile:
      case NetworkStatus.connectedMobileGood:
      case NetworkStatus.connectedMobilePoor:
        return true;
      default:
        return false;
    }
  }

  bool get isGoodQuality {
    switch (this) {
      case NetworkStatus.connectedWifiGood:
      case NetworkStatus.connectedMobileGood:
        return true;
      default:
        return false;
    }
  }

  bool get isPoorQuality {
    switch (this) {
      case NetworkStatus.connectedWifiPoor:
      case NetworkStatus.connectedMobilePoor:
        return true;
      default:
        return false;
    }
  }

  String get displayName {
    switch (this) {
      case NetworkStatus.unknown:
        return 'Unbekannt';
      case NetworkStatus.disconnected:
        return 'Nicht verbunden';
      case NetworkStatus.connectedNoInternet:
        return 'Verbunden, kein Internet';
      case NetworkStatus.connectedWifi:
        return 'WLAN verbunden';
      case NetworkStatus.connectedWifiGood:
        return 'WLAN (gut)';
      case NetworkStatus.connectedWifiPoor:
        return 'WLAN (schwach)';
      case NetworkStatus.connectedMobile:
        return 'Mobil verbunden';
      case NetworkStatus.connectedMobileGood:
        return 'Mobil (gut)';
      case NetworkStatus.connectedMobilePoor:
        return 'Mobil (schwach)';
      case NetworkStatus.connectedEthernet:
        return 'Ethernet verbunden';
    }
  }
}
