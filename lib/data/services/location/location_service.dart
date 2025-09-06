import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/models/waypoint.dart';

/// Service für GPS-Tracking und Location-Management
/// 
/// Bietet Funktionalität für:
/// - Echtzeit GPS-Position-Streams
/// - Distanz- und Richtungsberechnung
/// - Wegpunkt-Erreichung-Erkennung
/// - Background Location Tracking
class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._internal();
  
  LocationService._internal();

  StreamController<Position>? _positionStreamController;
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastKnownPosition;
  bool _isTracking = false;

  // Configuration constants
  static const double _waypointReachRadiusMeters = 10.0; // 10 Meter Radius
  static const int _locationUpdateIntervalMs = 2000; // 2 Sekunden
  static const int _minimumDistanceFilterMeters = 5; // 5 Meter minimum bewegung

  /// Aktuelle GPS-Position als Stream
  Stream<Position> get positionStream {
    if (_positionStreamController == null || _positionStreamController!.isClosed) {
      _positionStreamController = StreamController<Position>.broadcast();
    }
    return _positionStreamController!.stream;
  }

  /// Letzte bekannte Position
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Ob GPS-Tracking aktiv ist
  bool get isTracking => _isTracking;

  /// Initialisiert den LocationService und prüft Berechtigungen
  Future<bool> initialize() async {
    try {
      // Prüfe ob Location Services aktiviert sind
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('Location services are disabled.');
        return false;
      }

      // Prüfe Location Berechtigung
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('Location permissions are denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log('Location permissions are permanently denied, cannot request permissions.');
        return false;
      }

      // Lade letzte bekannte Position
      try {
        _lastKnownPosition = await Geolocator.getLastKnownPosition();
      } catch (e) {
        log('Error getting last known position: $e');
      }

      log('LocationService initialized successfully');
      return true;
    } catch (e) {
      log('Error initializing LocationService: $e');
      return false;
    }
  }

  /// Startet das GPS-Tracking
  Future<bool> startTracking() async {
    if (_isTracking) {
      log('GPS tracking is already active');
      return true;
    }

    try {
      // Initialisiere falls noch nicht geschehen
      bool initialized = await initialize();
      if (!initialized) {
        return false;
      }

      // Konfiguriere Location Settings für hohe Genauigkeit
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _minimumDistanceFilterMeters,
        timeLimit: Duration(seconds: 30), // Timeout für Position requests
      );

      // Starte Position Stream
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _lastKnownPosition = position;
          
          // Broadcastе Position über unseren eigenen Stream
          if (_positionStreamController != null && !_positionStreamController!.isClosed) {
            _positionStreamController!.add(position);
          }

          log('GPS position updated: ${position.latitude}, ${position.longitude} (Accuracy: ${position.accuracy}m)');
        },
        onError: (error) {
          log('Error in GPS position stream: $error');
          if (_positionStreamController != null && !_positionStreamController!.isClosed) {
            _positionStreamController!.addError(error);
          }
        },
      );

      _isTracking = true;
      log('GPS tracking started successfully');
      return true;
    } catch (e) {
      log('Error starting GPS tracking: $e');
      return false;
    }
  }

  /// Stoppt das GPS-Tracking
  Future<void> stopTracking() async {
    if (!_isTracking) {
      return;
    }

    try {
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
      _isTracking = false;
      
      log('GPS tracking stopped');
    } catch (e) {
      log('Error stopping GPS tracking: $e');
    }
  }

  /// Berechnet die Distanz zwischen aktueller Position und einem Waypoint
  /// Returns null wenn keine aktuelle Position verfügbar ist
  double? calculateDistanceToWaypoint(Waypoint waypoint) {
    final currentPosition = _lastKnownPosition;
    if (currentPosition == null) {
      return null;
    }

    return Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      waypoint.latitude,
      waypoint.longitude,
    );
  }

  /// Berechnet die Richtung (Bearing) zur aktuellen Position zu einem Waypoint
  /// Returns null wenn keine aktuelle Position verfügbar ist
  /// Bearing in Grad (0-360, 0 = Nord)
  double? calculateBearingToWaypoint(Waypoint waypoint) {
    final currentPosition = _lastKnownPosition;
    if (currentPosition == null) {
      return null;
    }

    return Geolocator.bearingBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      waypoint.latitude,
      waypoint.longitude,
    );
  }

  /// Prüft ob ein Waypoint erreicht wurde (innerhalb des definierten Radius)
  bool isWaypointReached(Waypoint waypoint) {
    final distance = calculateDistanceToWaypoint(waypoint);
    if (distance == null) {
      return false;
    }

    return distance <= _waypointReachRadiusMeters;
  }

  /// Findet den nächsten Waypoint aus einer Liste
  /// Returns null wenn keine Position verfügbar ist
  Waypoint? findNearestWaypoint(List<Waypoint> waypoints) {
    if (waypoints.isEmpty || _lastKnownPosition == null) {
      return null;
    }

    Waypoint? nearestWaypoint;
    double? nearestDistance;

    for (final waypoint in waypoints) {
      final distance = calculateDistanceToWaypoint(waypoint);
      if (distance != null) {
        if (nearestDistance == null || distance < nearestDistance) {
          nearestDistance = distance;
          nearestWaypoint = waypoint;
        }
      }
    }

    return nearestWaypoint;
  }

  /// Berechnet geschätzte Ankunftszeit zu einem Waypoint
  /// Basierend auf Gehgeschwindigkeit von ~4km/h
  Duration? calculateEstimatedTimeToWaypoint(Waypoint waypoint) {
    final distance = calculateDistanceToWaypoint(waypoint);
    if (distance == null) {
      return null;
    }

    // Durchschnittliche Gehgeschwindigkeit: 4 km/h = 1.11 m/s
    const double averageWalkingSpeedMs = 1.11;
    final double timeInSeconds = distance / averageWalkingSpeedMs;
    
    return Duration(seconds: timeInSeconds.round());
  }

  /// Konvertiert Bearing in Richtungstext (z.B. "Nord", "Nordost")
  String bearingToDirectionText(double bearing) {
    // Normalisiere bearing auf 0-360
    bearing = bearing % 360;
    if (bearing < 0) bearing += 360;

    const List<String> directions = [
      'Nord', 'Nordost', 'Ost', 'Südost',
      'Süd', 'Südwest', 'West', 'Nordwest'
    ];

    final int index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Formatiert Distanz in lesbarer Form (m oder km)
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }

  /// Formatiert Dauer in lesbarer Form
  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}min';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}min';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Öffnet die System-Einstellungen für Location Services
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      log('Error opening location settings: $e');
    }
  }

  /// Öffnet die App-Einstellungen für Location-Berechtigungen
  Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      log('Error opening app settings: $e');
    }
  }

  /// Cleanup-Methode für Ressourcen
  Future<void> dispose() async {
    await stopTracking();
    await _positionStreamController?.close();
    _positionStreamController = null;
  }

  /// Holt die aktuelle Position einmalig (ohne Stream)
  Future<Position?> getCurrentPosition() async {
    try {
      bool initialized = await initialize();
      if (!initialized) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );
    } catch (e) {
      log('Error getting current position: $e');
      return null;
    }
  }

  /// Prüft ob Background Location verfügbar ist
  Future<bool> isBackgroundLocationEnabled() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always;
    } catch (e) {
      log('Error checking background location permission: $e');
      return false;
    }
  }

  /// Fordert Background Location Berechtigung an
  Future<bool> requestBackgroundLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always;
    } catch (e) {
      log('Error requesting background location permission: $e');
      return false;
    }
  }
}