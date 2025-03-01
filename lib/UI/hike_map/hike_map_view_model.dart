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
    Future.microtask(() => notifyListeners());
    
    try {
      final waypoints = await waypointRepository.getWaypointsForHike(hikeId);
      _waypoints = waypoints;
      
      if (_waypoints.isNotEmpty) {
        await _calculateRoute();
      }
      
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Fehler beim Laden der Wegpunkte: $e';
      print(_errorMessage);
      Future.microtask(() => notifyListeners());
      // Wir werfen den Fehler nicht weiter, damit die App nicht abstürzt
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
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0]['geometry']['coordinates'] as List;
        
        _routePoints = route.map<List<double>>((point) {
          // OSRM gibt Koordinaten als [longitude, latitude] zurück, wir brauchen [latitude, longitude]
          return [point[1] as double, point[0] as double];
        }).toList();
        
        Future.microtask(() => notifyListeners());
      }
    } catch (e) {
      print('Fehler bei der Routenberechnung: $e');
      // Auch hier werfen wir den Fehler nicht weiter
    }
  }
  
  Future<void> updateCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _currentPosition = position;
      _checkIfNearWaypoint();
      Future.microtask(() => notifyListeners());
    } catch (e) {
      print('Fehler beim Aktualisieren der Position: $e');
    }
  }
  
  void _checkIfNearWaypoint() {
    if (_currentPosition == null || _waypoints.isEmpty) {
      _isNearWaypoint = false;
      return;
    }
    
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
        Future.microtask(() => notifyListeners());
        return;
      }
    }
    
    _isNearWaypoint = false;
    Future.microtask(() => notifyListeners());
  }
  
  // Wählt einen Wegpunkt aus
  void selectWaypoint(Waypoint waypoint) {
    _selectedWaypoint = waypoint;
    Future.microtask(() => notifyListeners());
  }
  
  // Hebt die Auswahl eines Wegpunkts auf
  void clearSelectedWaypoint() {
    _selectedWaypoint = null;
    Future.microtask(() => notifyListeners());
  }
} 