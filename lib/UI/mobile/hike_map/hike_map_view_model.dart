import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/models/waypoint.dart';
import '../../../data/repositories/waypoint_repository.dart';
import '../../../data/services/location/location_service.dart';
import '../../../data/services/navigation/navigation_service.dart';

enum LocationPermissionStatus { unknown, granted, denied, deniedForever }

class HikeMapViewModel extends ChangeNotifier {
  final int hikeId;
  final WaypointRepository waypointRepository;
  final LocationService _locationService = LocationService.instance;
  final NavigationService _navigationService = NavigationService.instance;

  List<Waypoint> _waypoints = [];
  bool _isLoading = false;
  String? _error;
  Waypoint? _selectedWaypoint;
  LocationPermissionStatus _locationPermissionStatus =
      LocationPermissionStatus.unknown;

  // GPS-related state
  Position? _currentPosition;
  bool _isGpsEnabled = false;
  bool _isNavigationActive = false;
  StreamSubscription<Position>? _positionSubscription;

  HikeMapViewModel({required this.hikeId, required this.waypointRepository}) {
    _initializeGpsServices();
  }

  // Basic getters
  List<Waypoint> get waypoints => _waypoints;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Waypoint? get selectedWaypoint => _selectedWaypoint;
  LocationPermissionStatus get locationPermissionStatus =>
      _locationPermissionStatus;

  // GPS-related getters
  Position? get currentPosition => _currentPosition;
  bool get isGpsEnabled => _isGpsEnabled;
  bool get isNavigationActive => _isNavigationActive;
  NavigationService get navigationService => _navigationService;

  // Convenience getters
  LatLng? get currentLatLng => _currentPosition != null
      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
      : null;

  void selectWaypoint(Waypoint? waypoint) {
    _selectedWaypoint = waypoint;
    notifyListeners();
  }

  /// Initialisiert GPS Services
  Future<void> _initializeGpsServices() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationPermissionStatus = LocationPermissionStatus.denied;
        _isGpsEnabled = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _locationPermissionStatus = LocationPermissionStatus.deniedForever;
        _isGpsEnabled = false;
        notifyListeners();
        return;
      }

      if (permission == LocationPermission.denied) {
        _locationPermissionStatus = LocationPermissionStatus.denied;
        _isGpsEnabled = false;
        notifyListeners();
        return;
      }

      _locationPermissionStatus = LocationPermissionStatus.granted;
      _isGpsEnabled = await _locationService.initialize();
      if (_isGpsEnabled) {
        await _startGpsTracking();
      }
    } catch (e) {
      log('Error initializing GPS services: $e');
      _isGpsEnabled = false;
      _locationPermissionStatus = LocationPermissionStatus.denied;
    }
    notifyListeners();
  }

  /// Startet GPS-Tracking
  Future<void> _startGpsTracking() async {
    try {
      bool trackingStarted = await _locationService.startTracking();
      if (trackingStarted) {
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
      bool navigationStarted = await _navigationService.startNavigation(
        _waypoints,
      );
      if (navigationStarted) {
        _isNavigationActive = true;
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
        _error =
            'GPS konnte nicht aktiviert werden. Bitte überprüfen Sie die Berechtigung.';
      }
    }
    notifyListeners();
  }

  void centerOnCurrentPosition() {
    if (_currentPosition != null) {
      notifyListeners();
    }
  }

  String? getDistanceToWaypoint(Waypoint waypoint) {
    if (_currentPosition == null) return null;
    final distance = _locationService.calculateDistanceToWaypoint(waypoint);
    return distance != null ? _locationService.formatDistance(distance) : null;
  }

  String? getBearingToWaypoint(Waypoint waypoint) {
    if (_currentPosition == null) return null;
    final bearing = _locationService.calculateBearingToWaypoint(waypoint);
    return bearing != null
        ? _locationService.bearingToDirectionText(bearing)
        : null;
  }

  bool isWaypointNearby(Waypoint waypoint, {double thresholdMeters = 50.0}) {
    if (_currentPosition == null) return false;
    final distance = _locationService.calculateDistanceToWaypoint(waypoint);
    return distance != null && distance <= thresholdMeters;
  }

  Waypoint? findNearestWaypoint() {
    return _locationService.findNearestWaypoint(_waypoints);
  }

  Future<void> loadWaypoints() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _waypoints =
          List.from(await waypointRepository.getWaypointsForHike(hikeId));

      if (_waypoints.isEmpty || _hasOverlappingCoordinates()) {
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
      final index = _waypoints.indexWhere((w) => w.id == waypoint.id);
      if (index != -1) {
        _waypoints[index] = updatedWaypoint;
        // Keep selection in sync if the toggled waypoint is selected
        if (_selectedWaypoint?.id == waypoint.id) {
          _selectedWaypoint = updatedWaypoint;
        }
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  LatLng getCurrentCenter() {
    if (_waypoints.isEmpty) {
      return const LatLng(51.1657, 10.4515);
    }

    try {
      final centerLat =
          _waypoints.map((w) => w.latitude).reduce((a, b) => a + b) /
          _waypoints.length;
      final centerLng =
          _waypoints.map((w) => w.longitude).reduce((a, b) => a + b) /
          _waypoints.length;

      return LatLng(centerLat, centerLng);
    } catch (e) {
      return const LatLng(51.1657, 10.4515);
    }
  }

  bool _hasOverlappingCoordinates() {
    if (_waypoints.length <= 1) return false;

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
      varianceLat +=
          (waypoint.latitude - avgLat) * (waypoint.latitude - avgLat);
      varianceLng +=
          (waypoint.longitude - avgLng) * (waypoint.longitude - avgLng);
    }

    double stdDevLat = (varianceLat / _waypoints.length);
    double stdDevLng = (varianceLng / _waypoints.length);

    return stdDevLat < 0.001 && stdDevLng < 0.001;
  }

  void _generateTestWaypoints() {
    List<Waypoint> originalWaypoints = List.from(_waypoints);
    _waypoints.clear();

    double baseLat = 51.1657;
    double baseLng = 10.4515;

    for (int i = 0; i < 5; i++) {
      double latOffset = (i - 2) * 0.01;
      double lngOffset = (i - 2) * 0.02;

      Waypoint waypoint;

      if (i < originalWaypoints.length) {
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
        waypoint = Waypoint(
          id: i + 1,
          hikeId: hikeId,
          name: 'Wegpunkt ${i + 1}',
          description: 'Beschreibung für Wegpunkt ${i + 1}',
          latitude: baseLat + latOffset,
          longitude: baseLng + lngOffset,
          orderIndex: i + 1,
          images: [],
          isVisited: i % 2 == 0,
        );
      }

      _waypoints.add(waypoint);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _navigationService.removeListener(_onNavigationUpdate);
    _locationService.stopTracking();
    if (_isNavigationActive) {
      _navigationService.stopNavigation();
    }
    super.dispose();
  }
}
