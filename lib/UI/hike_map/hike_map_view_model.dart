import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../data/repositories/waypoint_repository.dart';
import '../../domain/models/waypoint.dart';

class HikeMapViewModel extends ChangeNotifier {
  final WaypointRepository waypointRepository;
  
  List<Waypoint> _waypoints = [];
  List<Waypoint> get waypoints => _waypoints;
  
  List<List<double>> _routePoints = [];
  List<List<double>> get routePoints => _routePoints;
  
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;
  
  Waypoint? _selectedWaypoint;
  Waypoint? get selectedWaypoint => _selectedWaypoint;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  bool _isNearWaypoint = false;
  bool get isNearWaypoint => _isNearWaypoint;
  
  // Maximale Entfernung in Metern, um einen Wegpunkt als "erreicht" zu markieren
  static const double _maxDistanceToWaypoint = 50.0;
  
  HikeMapViewModel({required this.waypointRepository});
  
  Future<void> loadWaypointsForHike(int hikeId) async {
    _isLoading = true;
    _errorMessage = null;
    _waypoints = []; // Leere die Wegpunkte, um sicherzustellen, dass keine alten Daten angezeigt werden
    _routePoints = []; // Leere auch die Routenpunkte
    _selectedWaypoint = null; // Setze den ausgewählten Wegpunkt zurück
    _isNearWaypoint = false; // Setze den Nähe-Status zurück
    
    try {
      // Sichere Benachrichtigung über UI-Änderungen
      if (hasListeners) {
        notifyListeners();
      }
      
      final waypoints = await waypointRepository.getWaypointsForHike(hikeId);
      
      // Prüfe, ob das ViewModel noch aktiv ist
      if (!hasListeners) return;
      
      _waypoints = waypoints;
      
      if (_waypoints.isNotEmpty) {
        await _calculateRoute();
      }
      
      _isLoading = false;
      
      // Sichere Benachrichtigung über UI-Änderungen
      if (hasListeners) {
        notifyListeners();
      }
    } catch (e) {
      // Prüfe, ob das ViewModel noch aktiv ist
      if (!hasListeners) return;
      
      _isLoading = false;
      _errorMessage = 'Fehler beim Laden der Wegpunkte - loadWaypointsForHike: $e';
      print(_errorMessage);
      
      // Sichere Benachrichtigung über UI-Änderungen
      if (hasListeners) {
        notifyListeners();
      }
    }
  }
  
  Future<void> _calculateRoute() async {
    if (_waypoints.length < 2) {
      return;
    }
    
    try {
      final coordinates = _waypoints.map((waypoint) => 
        '${waypoint.longitude},${waypoint.latitude}'
      ).join(';');
      
      // Konfigurierbare URL für den Routing-Dienst
      final String routingBaseUrl = dotenv.env['OSRM_API_URL'] ?? 'https://router.project-osrm.org';
      final response = await http.get(
        Uri.parse('$routingBaseUrl/route/v1/walking/$coordinates?overview=full&geometries=geojson')
      );
      
      // Prüfe, ob das ViewModel noch aktiv ist
      if (!hasListeners) return;
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0]['geometry']['coordinates'] as List;
        
        _routePoints = route.map<List<double>>((point) {
          // OSRM gibt Koordinaten als [longitude, latitude] zurück, wir brauchen [latitude, longitude]
          return [point[1] as double, point[0] as double];
        }).toList();
        
        // Sichere Benachrichtigung über UI-Änderungen
        if (hasListeners) {
          notifyListeners();
        }
      }
    } catch (e) {
      print('Fehler bei der Routenberechnung: $e');
      // Wir werfen den Fehler nicht weiter, damit die App nicht abstürzt
    }
  }
  
  Future<void> updateCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Prüfe, ob das ViewModel noch aktiv ist
      if (!hasListeners) return;
      
      _currentPosition = position;
      _checkIfNearWaypoint();
      
      // Sichere Benachrichtigung über UI-Änderungen
      if (hasListeners) {
        notifyListeners();
      }
    } catch (e) {
      print('Fehler beim Aktualisieren der Position: $e');
    }
  }
  
  void _checkIfNearWaypoint() {
    if (_currentPosition == null || _waypoints.isEmpty) {
      _isNearWaypoint = false;
      _selectedWaypoint = null;
      return;
    }
    
    bool foundNearbyWaypoint = false;
    
    for (final waypoint in _waypoints) {
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        waypoint.latitude,
        waypoint.longitude,
      );
      
      if (distance <= _maxDistanceToWaypoint) {
        _selectedWaypoint = waypoint;
        _isNearWaypoint = true;
        foundNearbyWaypoint = true;
        break;
      }
    }
    
    // Wenn kein Wegpunkt in der Nähe gefunden wurde, setze die Werte zurück
    if (!foundNearbyWaypoint) {
      _isNearWaypoint = false;
      // Wir setzen _selectedWaypoint nicht zurück, damit der Benutzer den zuletzt ausgewählten Wegpunkt weiterhin sehen kann
    }
    
    // Sichere Benachrichtigung über UI-Änderungen
    if (hasListeners) {
      notifyListeners();
    }
  }
  
  // Wählt einen Wegpunkt aus
  void selectWaypoint(Waypoint waypoint) {
    _selectedWaypoint = waypoint;
    // Sichere Benachrichtigung über UI-Änderungen
    if (hasListeners) {
      notifyListeners();
    }
  }
  
  // Hebt die Auswahl eines Wegpunkts auf
  void clearSelectedWaypoint() {
    _selectedWaypoint = null;
    // Sichere Benachrichtigung über UI-Änderungen
    if (hasListeners) {
      notifyListeners();
    }
  }
} 