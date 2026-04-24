import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../services/admin/route_management_service.dart';

/// Provider für die Verwaltung von Wanderrouten im Admin-Bereich
class RouteManagementProvider extends ChangeNotifier {
  final RouteManagementService _routeManagementService;

  RouteManagementProvider({RouteManagementService? routeManagementService})
    : _routeManagementService =
          routeManagementService ?? RouteManagementService();

  // State
  List<Map<String, dynamic>> _routes = [];
  Map<String, dynamic>? _selectedRoute;
  List<Map<String, dynamic>> _waypoints = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  // Getters
  List<Map<String, dynamic>> get routes => _routes;
  Map<String, dynamic>? get selectedRoute => _selectedRoute;
  List<Map<String, dynamic>> get waypoints => _waypoints;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  // State-Management-Methoden

  /// Setzt den Loading-Status
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Setzt den Upload-Status
  void setUploading(bool uploading) {
    _isUploading = uploading;
    notifyListeners();
  }

  /// Setzt eine Fehlermeldung
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Löscht die aktuelle Fehlermeldung
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Route-Management

  /// Lädt alle Routen
  Future<void> loadRoutes() async {
    setLoading(true);
    clearError();

    try {
      log('Loading routes...');
      _routes = await _routeManagementService.getAllRoutesForAdmin();
      log('Loaded ${_routes.length} routes');
    } catch (e) {
      log('Error loading routes: $e');
      setError('Fehler beim Laden der Routen: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Erstellt eine neue Route
  Future<void> createRoute(Map<String, dynamic> routeData) async {
    setLoading(true);
    clearError();

    try {
      log('Creating new route: ${routeData['name']}');

      // Validiere Daten
      if (!_routeManagementService.validateRouteData(routeData)) {
        throw Exception('Ungültige Route-Daten');
      }

      await _routeManagementService.createRoute(routeData);

      // Lade Routen neu, um die neue Route anzuzeigen
      await loadRoutes();

      log('Route created successfully');
    } catch (e) {
      log('Error creating route: $e');
      setError('Fehler beim Erstellen der Route: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Aktualisiert eine bestehende Route
  Future<void> updateRoute(int routeId, Map<String, dynamic> updateData) async {
    setLoading(true);
    clearError();

    try {
      log('Updating route $routeId');

      await _routeManagementService.updateRoute(routeId, updateData);

      // Lade Routen neu, um die Änderungen anzuzeigen
      await loadRoutes();

      // Aktualisiere ausgewählte Route falls sie betroffen ist
      if (_selectedRoute != null && _selectedRoute!['id'] == routeId) {
        _selectedRoute = _routes.firstWhere(
          (route) => route['id'] == routeId,
          orElse: () => _selectedRoute!,
        );
      }

      log('Route updated successfully');
    } catch (e) {
      log('Error updating route: $e');
      setError('Fehler beim Aktualisieren der Route: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Löscht eine Route
  Future<void> deleteRoute(int routeId) async {
    setLoading(true);
    clearError();

    try {
      log('Deleting route $routeId');

      await _routeManagementService.deleteRoute(routeId);

      // Entferne Route aus lokaler Liste
      _routes.removeWhere((route) => route['id'] == routeId);

      // Deselektiere Route falls sie ausgewählt war
      if (_selectedRoute != null && _selectedRoute!['id'] == routeId) {
        _selectedRoute = null;
        _waypoints = [];
      }

      log('Route deleted successfully');
    } catch (e) {
      log('Error deleting route: $e');
      setError('Fehler beim Löschen der Route: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Wählt eine Route aus und lädt deren Wegpunkte
  Future<void> selectRoute(Map<String, dynamic> route) async {
    _selectedRoute = route;
    notifyListeners();

    try {
      log('Selecting route: ${route['name']}');
      await loadWaypoints(route['id']);
    } catch (e) {
      log('Error selecting route: $e');
      setError('Fehler beim Laden der Wegpunkte: $e');
    }
  }

  /// Deselektiert die aktuelle Route
  void deselectRoute() {
    _selectedRoute = null;
    _waypoints = [];
    notifyListeners();
  }

  // Wegpunkt-Management

  /// Lädt die Wegpunkte für eine bestimmte Route
  Future<void> loadWaypoints(int routeId) async {
    setLoading(true);
    clearError();

    try {
      log('Loading waypoints for route $routeId');
      _waypoints = await _routeManagementService.getRouteWaypoints(routeId);
      log('Loaded ${_waypoints.length} waypoints');
    } catch (e) {
      log('Error loading waypoints: $e');
      setError('Fehler beim Laden der Wegpunkte: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Fügt einen neuen Wegpunkt zu einer Route hinzu
  Future<void> addWaypoint(
    int routeId,
    Map<String, dynamic> waypointData,
  ) async {
    setLoading(true);
    clearError();

    try {
      log('Adding waypoint to route $routeId: ${waypointData['name']}');

      // Validiere Wegpunkt-Daten
      if (!_routeManagementService.validateWaypointData(waypointData)) {
        throw Exception('Ungültige Wegpunkt-Daten');
      }

      // Setze automatisch den nächsten order_index wenn nicht angegeben
      if (!waypointData.containsKey('order_index')) {
        waypointData['order_index'] = _waypoints.length + 1;
      }

      await _routeManagementService.addWaypointToRoute(routeId, waypointData);

      // Lade Wegpunkte neu
      await loadWaypoints(routeId);

      log('Waypoint added successfully');
    } catch (e) {
      log('Error adding waypoint: $e');
      setError('Fehler beim Hinzufügen des Wegpunkts: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Aktualisiert einen Wegpunkt
  Future<void> updateWaypoint(
    int waypointId,
    Map<String, dynamic> updateData,
  ) async {
    setLoading(true);
    clearError();

    try {
      log('Updating waypoint $waypointId');

      await _routeManagementService.updateWaypoint(waypointId, updateData);

      // Lade Wegpunkte neu falls eine Route ausgewählt ist
      if (_selectedRoute != null) {
        await loadWaypoints(_selectedRoute!['id']);
      }

      log('Waypoint updated successfully');
    } catch (e) {
      log('Error updating waypoint: $e');
      setError('Fehler beim Aktualisieren des Wegpunkts: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Entfernt einen Wegpunkt von einer Route
  Future<void> removeWaypoint(int routeId, int waypointId) async {
    setLoading(true);
    clearError();

    try {
      log('Removing waypoint $waypointId from route $routeId');

      await _routeManagementService.removeWaypointFromRoute(
        routeId,
        waypointId,
      );

      // Entferne Wegpunkt aus lokaler Liste
      _waypoints.removeWhere(
        (waypoint) => waypoint['waypoints']['id'] == waypointId,
      );

      log('Waypoint removed successfully');
    } catch (e) {
      log('Error removing waypoint: $e');
      setError('Fehler beim Entfernen des Wegpunkts: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Ändert die Reihenfolge der Wegpunkte
  Future<void> reorderWaypoints(
    int routeId,
    List<Map<String, dynamic>> newOrder,
  ) async {
    setLoading(true);
    clearError();

    try {
      log('Reordering waypoints for route $routeId');

      await _routeManagementService.updateWaypointOrder(routeId, newOrder);

      // Lade Wegpunkte neu um die neue Reihenfolge anzuzeigen
      await loadWaypoints(routeId);

      log('Waypoints reordered successfully');
    } catch (e) {
      log('Error reordering waypoints: $e');
      setError('Fehler beim Neuordnen der Wegpunkte: $e');
    } finally {
      setLoading(false);
    }
  }

  // Bild-Management

  /// Lädt ein Bild für eine Route hoch
  Future<String?> uploadRouteImage(
    int routeId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    setUploading(true);
    clearError();

    try {
      log('Uploading image for route $routeId: $fileName');

      final imageUrl = await _routeManagementService.uploadRouteImage(
        routeId,
        imageBytes,
        fileName,
      );

      log('Image uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {
      log('Error uploading image: $e');
      setError('Fehler beim Hochladen des Bildes: $e');
      return null;
    } finally {
      setUploading(false);
    }
  }

  /// Löscht ein Bild einer Route
  Future<void> deleteRouteImage(int routeId, String fileName) async {
    clearError();

    try {
      log('Deleting image for route $routeId: $fileName');

      await _routeManagementService.deleteRouteImage(routeId, fileName);

      log('Image deleted successfully');
    } catch (e) {
      log('Error deleting image: $e');
      setError('Fehler beim Löschen des Bildes: $e');
    }
  }

  /// Lädt ein Bild für einen Wegpunkt hoch
  Future<String?> uploadWaypointImage(
    int waypointId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    setUploading(true);
    clearError();

    try {
      log('Uploading image for waypoint $waypointId: $fileName');

      final imageUrl = await _routeManagementService.uploadWaypointImage(
        waypointId,
        imageBytes,
        fileName,
      );

      log('Waypoint image uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {
      log('Error uploading waypoint image: $e');
      setError('Fehler beim Hochladen des Wegpunkt-Bildes: $e');
      return null;
    } finally {
      setUploading(false);
    }
  }

  // Hilfsmethoden

  /// Filtert Routen nach Suchbegriff
  List<Map<String, dynamic>> filterRoutes(String searchTerm) {
    if (searchTerm.isEmpty) {
      return _routes;
    }

    final lowerSearchTerm = searchTerm.toLowerCase();

    return _routes.where((route) {
      final name = route['name']?.toString().toLowerCase() ?? '';
      final description = route['description']?.toString().toLowerCase() ?? '';
      final difficulty = route['difficulty']?.toString().toLowerCase() ?? '';

      return name.contains(lowerSearchTerm) ||
          description.contains(lowerSearchTerm) ||
          difficulty.contains(lowerSearchTerm);
    }).toList();
  }

  /// Filtert Routen nach Status (aktiv/inaktiv)
  List<Map<String, dynamic>> filterRoutesByStatus(bool? isActive) {
    if (isActive == null) {
      return _routes;
    }

    return _routes.where((route) => route['is_active'] == isActive).toList();
  }

  /// Filtert Routen nach Schwierigkeitsgrad
  List<Map<String, dynamic>> filterRoutesByDifficulty(String? difficulty) {
    if (difficulty == null || difficulty.isEmpty) {
      return _routes;
    }

    return _routes.where((route) => route['difficulty'] == difficulty).toList();
  }

  /// Sortiert Routen nach verschiedenen Kriterien
  List<Map<String, dynamic>> sortRoutes(
    String sortBy, {
    bool ascending = true,
  }) {
    final sortedRoutes = List<Map<String, dynamic>>.from(_routes);

    sortedRoutes.sort((a, b) {
      dynamic valueA, valueB;

      switch (sortBy) {
        case 'name':
          valueA = a['name'] ?? '';
          valueB = b['name'] ?? '';
          break;
        case 'price':
          valueA = a['price'] ?? 0.0;
          valueB = b['price'] ?? 0.0;
          break;
        case 'distance':
          valueA = a['distance'] ?? 0.0;
          valueB = b['distance'] ?? 0.0;
          break;
        case 'duration':
          valueA = a['duration'] ?? 0;
          valueB = b['duration'] ?? 0;
          break;
        case 'created_at':
          valueA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
          valueB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
          break;
        default:
          valueA = a['name'] ?? '';
          valueB = b['name'] ?? '';
      }

      final comparison = valueA.compareTo(valueB);
      return ascending ? comparison : -comparison;
    });

    return sortedRoutes;
  }

  /// Berechnet Statistiken für die aktuelle Route-Auswahl
  Map<String, dynamic> getRouteStatistics() {
    if (_routes.isEmpty) {
      return {
        'totalRoutes': 0,
        'activeRoutes': 0,
        'inactiveRoutes': 0,
        'averagePrice': 0.0,
        'averageDistance': 0.0,
        'averageDuration': 0.0,
      };
    }

    final activeRoutes = _routes
        .where((route) => route['is_active'] == true)
        .length;
    final totalPrice = _routes.fold<double>(
      0.0,
      (sum, route) => sum + (route['price'] ?? 0.0),
    );
    final totalDistance = _routes.fold<double>(
      0.0,
      (sum, route) => sum + (route['distance'] ?? 0.0),
    );
    final totalDuration = _routes.fold<double>(
      0.0,
      (sum, route) => sum + (route['duration'] ?? 0.0),
    );

    return {
      'totalRoutes': _routes.length,
      'activeRoutes': activeRoutes,
      'inactiveRoutes': _routes.length - activeRoutes,
      'averagePrice': totalPrice / _routes.length,
      'averageDistance': totalDistance / _routes.length,
      'averageDuration': totalDuration / _routes.length,
    };
  }

  /// Berechnet die Distanz für die aktuelle Route basierend auf Wegpunkten
  Future<double> calculateSelectedRouteDistance() async {
    if (_selectedRoute == null) {
      return 0.0;
    }

    try {
      return await _routeManagementService.calculateRouteDistance(
        _selectedRoute!['id'],
      );
    } catch (e) {
      log('Error calculating route distance: $e');
      return 0.0;
    }
  }

  /// Generiert eine Vorschau-URL für die ausgewählte Route
  Future<String> generateSelectedRoutePreview() async {
    if (_selectedRoute == null) {
      return '';
    }

    try {
      return await _routeManagementService.generateRoutePreviewUrl(
        _selectedRoute!['id'],
      );
    } catch (e) {
      log('Error generating route preview: $e');
      return '';
    }
  }

  /// Löscht alle Daten (für Logout oder Reset)
  void clearData() {
    _routes = [];
    _selectedRoute = null;
    _waypoints = [];
    _isLoading = false;
    _isUploading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Prüft ob aktuell Änderungen an einer Route vorgenommen werden
  bool get hasUnsavedChanges => _isLoading || _isUploading;

  /// Gibt die Anzahl der Wegpunkte für die ausgewählte Route zurück
  int get waypointCount => _waypoints.length;

  /// Gibt die geschätzte Dauer für die ausgewählte Route zurück
  String get estimatedDuration {
    if (_selectedRoute == null) return '0h';

    final duration = _selectedRoute!['duration'] ?? 0;
    final hours = duration ~/ 60;
    final minutes = duration % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }
}
