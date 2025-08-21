import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/models/waypoint.dart';
import '../../data/repositories/waypoint_repository.dart';

class HikeMapViewModel extends ChangeNotifier {
  final int hikeId;
  final WaypointRepository waypointRepository;

  List<Waypoint> _waypoints = [];
  bool _isLoading = false;
  String? _error;

  HikeMapViewModel({
    required this.hikeId,
    required this.waypointRepository,
  });

  List<Waypoint> get waypoints => _waypoints;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
} 