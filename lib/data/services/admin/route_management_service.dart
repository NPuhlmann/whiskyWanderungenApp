import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service für die Verwaltung von Wanderrouten im Admin-Bereich
class RouteManagementService {
  final SupabaseClient _client;

  RouteManagementService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  // CRUD Operations für Routen

  /// Erstellt eine neue Wanderroute
  Future<Map<String, dynamic>> createRoute(
    Map<String, dynamic> routeData,
  ) async {
    try {
      log('Creating new route: ${routeData['name']}');

      // Füge Zeitstempel hinzu
      final dataWithTimestamp = {
        ...routeData,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('hikes')
          .insert(dataWithTimestamp)
          .select()
          .single();

      log('Route created successfully with ID: ${response['id']}');
      return response;
    } catch (e) {
      log('Error creating route: $e');
      rethrow;
    }
  }

  /// Holt eine spezifische Route anhand der ID
  Future<Map<String, dynamic>> getRouteById(int routeId) async {
    try {
      log('Fetching route with ID: $routeId');

      final response = await _client
          .from('hikes')
          .select()
          .eq('id', routeId)
          .single();

      log('Route fetched successfully: ${response['name']}');
      return response;
    } catch (e) {
      log('Error fetching route: $e');
      rethrow;
    }
  }

  /// Aktualisiert eine bestehende Route
  Future<Map<String, dynamic>> updateRoute(
    int routeId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      log('Updating route with ID: $routeId');

      // Füge Update-Zeitstempel hinzu
      final dataWithTimestamp = {
        ...updateData,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('hikes')
          .update(dataWithTimestamp)
          .eq('id', routeId)
          .select()
          .single();

      log('Route updated successfully: ${response['name']}');
      return response;
    } catch (e) {
      log('Error updating route: $e');
      rethrow;
    }
  }

  /// Löscht eine Route
  Future<void> deleteRoute(int routeId) async {
    try {
      log('Deleting route with ID: $routeId');

      await _client.from('hikes').delete().eq('id', routeId);

      log('Route deleted successfully');
    } catch (e) {
      log('Error deleting route: $e');
      rethrow;
    }
  }

  /// Holt alle Routen für den Admin-Bereich
  Future<List<Map<String, dynamic>>> getAllRoutesForAdmin() async {
    try {
      log('Fetching all routes for admin');

      final response = await _client
          .from('hikes')
          .select('''
            id,
            name,
            description,
            difficulty,
            distance,
            duration,
            price,
            max_participants,
            is_active,
            thumbnail_image_url,
            created_at,
            updated_at
          ''')
          .order('created_at', ascending: false);

      log('Fetched ${response.length} routes for admin');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error fetching admin routes: $e');
      rethrow;
    }
  }

  // Wegpunkt-Management

  /// Fügt einen Wegpunkt zu einer Route hinzu
  Future<Map<String, dynamic>> addWaypointToRoute(
    int routeId,
    Map<String, dynamic> waypointData,
  ) async {
    try {
      log('Adding waypoint to route $routeId: ${waypointData['name']}');

      // 1. Erstelle den Wegpunkt
      final waypointWithTimestamp = {
        ...waypointData,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final waypointResponse = await _client
          .from('waypoints')
          .insert(waypointWithTimestamp)
          .select()
          .single();

      final waypointId = waypointResponse['id'];
      log('Waypoint created with ID: $waypointId');

      // 2. Verknüpfe den Wegpunkt mit der Route
      await _client.from('hikes_waypoints').insert({
        'hike_id': routeId,
        'waypoint_id': waypointId,
        'order_index': waypointData['order_index'] ?? 1,
      }).select();

      log('Waypoint linked to route successfully');
      return waypointResponse;
    } catch (e) {
      log('Error adding waypoint to route: $e');
      rethrow;
    }
  }

  /// Aktualisiert die Reihenfolge der Wegpunkte einer Route
  Future<void> updateWaypointOrder(
    int routeId,
    List<Map<String, dynamic>> newOrder,
  ) async {
    try {
      log('Updating waypoint order for route $routeId');

      // Aktualisiere jeden Wegpunkt einzeln
      for (final orderItem in newOrder) {
        await _client
            .from('hikes_waypoints')
            .update({'order_index': orderItem['orderIndex']})
            .eq('hike_id', routeId)
            .eq('waypoint_id', orderItem['waypointId']);
      }

      log('Waypoint order updated successfully');
    } catch (e) {
      log('Error updating waypoint order: $e');
      rethrow;
    }
  }

  /// Entfernt einen Wegpunkt von einer Route
  Future<void> removeWaypointFromRoute(int routeId, int waypointId) async {
    try {
      log('Removing waypoint $waypointId from route $routeId');

      // Entferne die Verknüpfung zwischen Route und Wegpunkt
      await _client
          .from('hikes_waypoints')
          .delete()
          .eq('hike_id', routeId)
          .eq('waypoint_id', waypointId);

      log('Waypoint removed from route successfully');
    } catch (e) {
      log('Error removing waypoint from route: $e');
      rethrow;
    }
  }

  /// Holt alle Wegpunkte einer Route mit korrekter Reihenfolge
  Future<List<Map<String, dynamic>>> getRouteWaypoints(int routeId) async {
    try {
      log('Fetching waypoints for route $routeId');

      final response = await _client
          .from('hikes_waypoints')
          .select('''
            waypoint_id,
            order_index,
            waypoints (
              id,
              name,
              description,
              latitude,
              longitude,
              whisky_info,
              image_url,
              created_at,
              updated_at
            )
          ''')
          .eq('hike_id', routeId)
          .order('order_index');

      log('Fetched ${response.length} waypoints for route $routeId');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error fetching route waypoints: $e');
      rethrow;
    }
  }

  /// Aktualisiert einen Wegpunkt
  Future<Map<String, dynamic>> updateWaypoint(
    int waypointId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      log('Updating waypoint with ID: $waypointId');

      final dataWithTimestamp = {
        ...updateData,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('waypoints')
          .update(dataWithTimestamp)
          .eq('id', waypointId)
          .select()
          .single();

      log('Waypoint updated successfully');
      return response;
    } catch (e) {
      log('Error updating waypoint: $e');
      rethrow;
    }
  }

  // Bild-Management

  /// Lädt ein Bild für eine Route hoch
  Future<String> uploadRouteImage(
    int routeId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      log('Uploading image for route $routeId: $fileName');

      final path = 'route_$routeId/$fileName';

      await _client.storage
          .from('route_images')
          .uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = _client.storage.from('route_images').getPublicUrl(path);

      log('Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      log('Error uploading route image: $e');
      rethrow;
    }
  }

  /// Löscht ein Bild einer Route
  Future<void> deleteRouteImage(int routeId, String fileName) async {
    try {
      log('Deleting image for route $routeId: $fileName');

      final path = 'route_$routeId/$fileName';

      await _client.storage.from('route_images').remove([path]);

      log('Image deleted successfully');
    } catch (e) {
      log('Error deleting route image: $e');
      rethrow;
    }
  }

  /// Lädt ein Bild für einen Wegpunkt hoch
  Future<String> uploadWaypointImage(
    int waypointId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      log('Uploading image for waypoint $waypointId: $fileName');

      final path = 'waypoint_$waypointId/$fileName';

      await _client.storage
          .from('waypoint_images')
          .uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = _client.storage
          .from('waypoint_images')
          .getPublicUrl(path);

      log('Waypoint image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      log('Error uploading waypoint image: $e');
      rethrow;
    }
  }

  // Hilfsmethoden

  /// Validiert Route-Daten vor dem Speichern
  bool validateRouteData(Map<String, dynamic> routeData) {
    final requiredFields = [
      'name',
      'difficulty',
      'distance',
      'duration',
      'price',
    ];

    for (final field in requiredFields) {
      if (!routeData.containsKey(field) || routeData[field] == null) {
        log('Validation failed: Missing required field $field');
        return false;
      }
    }

    // Validiere Datentypen
    if (routeData['distance'] is! num) {
      log('Validation failed: distance must be a number');
      return false;
    }

    if (routeData['duration'] is! int) {
      log('Validation failed: duration must be an integer');
      return false;
    }

    if (routeData['price'] is! num) {
      log('Validation failed: price must be a number');
      return false;
    }

    final validDifficulties = ['easy', 'moderate', 'hard'];
    if (!validDifficulties.contains(routeData['difficulty'])) {
      log('Validation failed: Invalid difficulty level');
      return false;
    }

    return true;
  }

  /// Validiert Wegpunkt-Daten vor dem Speichern
  bool validateWaypointData(Map<String, dynamic> waypointData) {
    final requiredFields = ['name', 'latitude', 'longitude'];

    for (final field in requiredFields) {
      if (!waypointData.containsKey(field) || waypointData[field] == null) {
        log('Validation failed: Missing required waypoint field $field');
        return false;
      }
    }

    // Validiere Koordinaten
    final lat = waypointData['latitude'];
    final lng = waypointData['longitude'];

    if (lat is! num || lng is! num) {
      log('Validation failed: Coordinates must be numbers');
      return false;
    }

    if (lat < -90 || lat > 90) {
      log('Validation failed: Invalid latitude range');
      return false;
    }

    if (lng < -180 || lng > 180) {
      log('Validation failed: Invalid longitude range');
      return false;
    }

    return true;
  }

  /// Berechnet die Gesamtdistanz einer Route basierend auf den Wegpunkten
  Future<double> calculateRouteDistance(int routeId) async {
    try {
      final waypoints = await getRouteWaypoints(routeId);

      if (waypoints.length < 2) {
        return 0.0;
      }

      double totalDistance = 0.0;

      for (int i = 0; i < waypoints.length - 1; i++) {
        final current = waypoints[i]['waypoints'];
        final next = waypoints[i + 1]['waypoints'];

        totalDistance += _calculateDistanceBetweenPoints(
          current['latitude'],
          current['longitude'],
          next['latitude'],
          next['longitude'],
        );
      }

      log('Calculated route distance: ${totalDistance.toStringAsFixed(2)} km');
      return totalDistance;
    } catch (e) {
      log('Error calculating route distance: $e');
      return 0.0;
    }
  }

  /// Berechnet die Distanz zwischen zwei GPS-Punkten (Haversine-Formel)
  double _calculateDistanceBetweenPoints(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Erdradius in km

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Konvertiert Grad zu Radiant
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Generiert eine Vorschau-URL für eine Route basierend auf den Wegpunkten
  Future<String> generateRoutePreviewUrl(int routeId) async {
    try {
      final waypoints = await getRouteWaypoints(routeId);

      if (waypoints.isEmpty) {
        return '';
      }

      // Erstelle eine einfache Karten-URL (z.B. für OpenStreetMap oder Google Maps)
      final centerLat =
          waypoints
              .map((w) => w['waypoints']['latitude'] as double)
              .reduce((a, b) => a + b) /
          waypoints.length;
      final centerLng =
          waypoints
              .map((w) => w['waypoints']['longitude'] as double)
              .reduce((a, b) => a + b) /
          waypoints.length;

      // Beispiel für OpenStreetMap-basierte URL
      return 'https://www.openstreetmap.org/?mlat=$centerLat&mlon=$centerLng&zoom=12';
    } catch (e) {
      log('Error generating route preview URL: $e');
      return '';
    }
  }
}
