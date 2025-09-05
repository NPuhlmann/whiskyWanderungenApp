import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/models/waypoint.dart';
import '../../../data/repositories/waypoint_repository.dart';
import '../../../data/services/location/location_service.dart';
import '../../../data/services/navigation/navigation_service.dart';

class HikeMapViewModel extends ChangeNotifier {
  final int hikeId;
  final WaypointRepository waypointRepository;
  final LocationService _locationService = LocationService.instance;
  final NavigationService _navigationService = NavigationService.instance;

  List<Waypoint> _waypoints = [];
  bool _isLoading = false;
  String? _error;
  
  // GPS-related state
  Position? _currentPosition;
  bool _isGpsEnabled = false;
  bool _isNavigationActive = false;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<NavigationStatus>? _navigationSubscription;

  HikeMapViewModel({
    required this.hikeId,
    required this.waypointRepository,
  }) {
    _initializeGpsServices();
  }

  // Basic getters
  List<Waypoint> get waypoints => _waypoints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // GPS-related getters
  Position? get currentPosition => _currentPosition;
  bool get isGpsEnabled => _isGpsEnabled;
  bool get isNavigationActive => _isNavigationActive;
  NavigationService get navigationService => _navigationService;
  
  // Convenience getters
  LatLng? get currentLatLng => _currentPosition != null 
    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
    : null;

  /// Initialisiert GPS Services
  Future<void> _initializeGpsServices() async {
    try {
      _isGpsEnabled = await _locationService.initialize();
      if (_isGpsEnabled) {
        // Starte GPS Tracking
        await _startGpsTracking();
      }
    } catch (e) {
      log('Error initializing GPS services: $e');
      _isGpsEnabled = false;
    }
    notifyListeners();
  }

  /// Startet GPS-Tracking
  Future<void> _startGpsTracking() async {
    try {
      bool trackingStarted = await _locationService.startTracking();
      if (trackingStarted) {
        // Höre auf Position Updates
        _positionSubscription = _locationService.positionStream.listen(
          (position) {
            _currentPosition = position;
            notifyListeners();
          },
          onError: (error) {
            log('GPS position error: $error');
          },
        );
      }
    } catch (e) {
      log('Error starting GPS tracking: $e');
    }
  }

  /// Startet Navigation zu allen Waypoints
  Future<bool> startNavigation() async {
    if (_waypoints.isEmpty) {
      _error = 'Keine Waypoints für Navigation verfügbar';
      notifyListeners();
      return false;
    }

    try {
      bool navigationStarted = await _navigationService.startNavigation(_waypoints);
      if (navigationStarted) {
        _isNavigationActive = true;
        
        // Höre auf Navigation Status Updates
        _navigationService.addListener(_onNavigationUpdate);
        
        notifyListeners();
        return true;
      } else {
        _error = 'Navigation konnte nicht gestartet werden';
        notifyListeners();
        return false;
      }
    } catch (e) {
      log('Error starting navigation: $e');
      _error = 'Fehler beim Starten der Navigation: $e';
      notifyListeners();
      return false;
    }
  }

  /// Stoppt die Navigation
  Future<void> stopNavigation() async {
    try {
      await _navigationService.stopNavigation();
      _navigationService.removeListener(_onNavigationUpdate);
      _isNavigationActive = false;
      notifyListeners();
    } catch (e) {
      log('Error stopping navigation: $e');
    }
  }

  /// Pausiert die Navigation
  Future<void> pauseNavigation() async {
    await _navigationService.pauseNavigation();
    notifyListeners();
  }

  /// Setzt die Navigation fort
  Future<void> resumeNavigation() async {
    await _navigationService.resumeNavigation();
    notifyListeners();
  }

  /// Navigation Status Update Handler
  void _onNavigationUpdate() {
    notifyListeners();
  }

  /// Aktiviert/Deaktiviert GPS-Tracking
  Future<void> toggleGpsTracking() async {
    if (_isGpsEnabled && _locationService.isTracking) {
      await _locationService.stopTracking();
      await _positionSubscription?.cancel();
      _currentPosition = null;
    } else {
      bool initialized = await _locationService.initialize();
      if (initialized) {
        await _startGpsTracking();
        _isGpsEnabled = true;
      } else {
        _error = 'GPS konnte nicht aktiviert werden. Bitte überprüfen Sie die Berechtigung.';
      }
    }
    notifyListeners();
  }

  /// Zentriert die Karte auf die aktuelle Position
  void centerOnCurrentPosition() {
    if (_currentPosition != null) {
      notifyListeners(); // Dies wird vom UI verwendet um die Karte zu zentrieren
    }
  }

  /// Berechnet Distanz zu einem Waypoint
  String? getDistanceToWaypoint(Waypoint waypoint) {
    if (_currentPosition == null) return null;
    
    final distance = _locationService.calculateDistanceToWaypoint(waypoint);
    return distance != null ? _locationService.formatDistance(distance) : null;
  }

  /// Berechnet Richtung zu einem Waypoint
  String? getBearingToWaypoint(Waypoint waypoint) {
    if (_currentPosition == null) return null;
    
    final bearing = _locationService.calculateBearingToWaypoint(waypoint);
    return bearing != null ? _locationService.bearingToDirectionText(bearing) : null;
  }

  /// Prüft ob ein Waypoint in der Nähe ist (für UI Hervorhebung)
  bool isWaypointNearby(Waypoint waypoint, {double thresholdMeters = 50.0}) {
    if (_currentPosition == null) return false;
    
    final distance = _locationService.calculateDistanceToWaypoint(waypoint);
    return distance != null && distance <= thresholdMeters;
  }

  /// Findet den nächstgelegenen Waypoint
  Waypoint? findNearestWaypoint() {
    return _locationService.findNearestWaypoint(_waypoints);
  }

  Future<void> loadWaypoints() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _waypoints = await waypointRepository.getWaypointsForHike(hikeId);
      
      // Überprüfen, ob die Wegpunkte unterschiedliche Koordinaten haben
      if (_waypoints.isEmpty || _hasOverlappingCoordinates()) {
        // Wenn keine Wegpunkte vorhanden sind oder alle an der gleichen Position,
        // generiere Testdaten mit unterschiedlichen Koordinaten
        _generateTestWaypoints();
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWaypointVisited(Waypoint waypoint) async {
    final updatedWaypoint = Waypoint(
      id: waypoint.id,
      hikeId: waypoint.hikeId,
      name: waypoint.name,
      description: waypoint.description,
      latitude: waypoint.latitude,
      longitude: waypoint.longitude,
      orderIndex: waypoint.orderIndex,
      images: waypoint.images,
      isVisited: !waypoint.isVisited,
    );

    try {
      // Da es keinen is_visited Marker in der Tabelle gibt, speichern wir den Status nur lokal
      // In einer vollständigen Implementierung würden wir eine separate Tabelle für besuchte Wegpunkte erstellen
      
      // Aktualisiere den Wegpunkt in der lokalen Liste
      final index = _waypoints.indexWhere((w) => w.id == waypoint.id);
      if (index != -1) {
        _waypoints[index] = updatedWaypoint;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  LatLng getCurrentCenter() {
    if (_waypoints.isEmpty) {
      // Standardwert für Deutschland, falls keine Wegpunkte vorhanden sind
      return const LatLng(51.1657, 10.4515);
    }

    try {
      final centerLat = _waypoints.map((w) => w.latitude).reduce((a, b) => a + b) / _waypoints.length;
      final centerLng = _waypoints.map((w) => w.longitude).reduce((a, b) => a + b) / _waypoints.length;
      
      return LatLng(centerLat, centerLng);
    } catch (e) {
      // Fallback, falls ein Fehler bei der Berechnung auftritt
      return const LatLng(51.1657, 10.4515);
    }
  }

  // Überprüft, ob die Wegpunkte unterschiedliche Koordinaten haben
  bool _hasOverlappingCoordinates() {
    if (_waypoints.length <= 1) return false;
    
    // Berechne die Standardabweichung der Koordinaten
    double sumLat = 0;
    double sumLng = 0;
    
    for (var waypoint in _waypoints) {
      sumLat += waypoint.latitude;
      sumLng += waypoint.longitude;
    }
    
    double avgLat = sumLat / _waypoints.length;
    double avgLng = sumLng / _waypoints.length;
    
    double varianceLat = 0;
    double varianceLng = 0;
    
    for (var waypoint in _waypoints) {
      varianceLat += (waypoint.latitude - avgLat) * (waypoint.latitude - avgLat);
      varianceLng += (waypoint.longitude - avgLng) * (waypoint.longitude - avgLng);
    }
    
    double stdDevLat = (varianceLat / _waypoints.length);
    double stdDevLng = (varianceLng / _waypoints.length);
    
    // Wenn die Standardabweichung sehr klein ist, sind die Punkte wahrscheinlich zu nah beieinander
    return stdDevLat < 0.001 && stdDevLng < 0.001;
  }
  
  // Generiert Testdaten mit unterschiedlichen Koordinaten
  void _generateTestWaypoints() {
    // Speichere die ursprünglichen Wegpunkte
    List<Waypoint> originalWaypoints = List.from(_waypoints);
    
    // Lösche die aktuellen Wegpunkte
    _waypoints.clear();
    
    // Startpunkt für die Testdaten (Deutschland)
    double baseLat = 51.1657;
    double baseLng = 10.4515;
    
    // Generiere 5 Testpunkte mit unterschiedlichen Koordinaten
    for (int i = 0; i < 5; i++) {
      // Berechne Offset für die Koordinaten
      double latOffset = (i - 2) * 0.01;
      double lngOffset = (i - 2) * 0.02;
      
      // Erstelle einen neuen Wegpunkt
      Waypoint waypoint;
      
      if (i < originalWaypoints.length) {
        // Verwende die Daten des ursprünglichen Wegpunkts, aber mit neuen Koordinaten
        waypoint = Waypoint(
          id: originalWaypoints[i].id,
          hikeId: hikeId,
          name: originalWaypoints[i].name,
          description: originalWaypoints[i].description,
          latitude: baseLat + latOffset,
          longitude: baseLng + lngOffset,
          orderIndex: originalWaypoints[i].orderIndex,
          images: originalWaypoints[i].images,
          isVisited: originalWaypoints[i].isVisited,
        );
      } else {
        // Erstelle einen neuen Testpunkt
        waypoint = Waypoint(
          id: i + 1,
          hikeId: hikeId,
          name: 'Wegpunkt ${i + 1}',
          description: 'Beschreibung für Wegpunkt ${i + 1}',
          latitude: baseLat + latOffset,
          longitude: baseLng + lngOffset,
          orderIndex: i + 1,
          images: [],
          isVisited: i % 2 == 0, // Abwechselnd besucht/nicht besucht
        );
      }
      
      _waypoints.add(waypoint);
    }
  }

  @override
  void dispose() {
    // Cleanup GPS resources
    _positionSubscription?.cancel();
    _navigationService.removeListener(_onNavigationUpdate);
    
    // Stop services
    _locationService.stopTracking();
    if (_isNavigationActive) {
      _navigationService.stopNavigation();
    }
    
    super.dispose();
  }
} 