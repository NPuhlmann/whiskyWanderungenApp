import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/waypoint.dart';
import '../services/database/backend_api.dart';

class WaypointRepository {
  final BackendApiService _backendApiService;

  WaypointRepository(this._backendApiService);

  Future<List<Waypoint>> getWaypointsForHike(int hikeId) async {
    try {
      final response = await _backendApiService.client
          .from('waypoints')
          .select('*, waypoint_images(image_url)')
          .eq('hike_id', hikeId)
          .order('order_index');

      return response.map<Waypoint>((data) {
        // Extrahiere die Bilder-URLs aus der waypoint_images-Relation
        final List<String> images = [];
        if (data['waypoint_images'] != null) {
          for (final image in data['waypoint_images']) {
            if (image['image_url'] != null) {
              images.add(image['image_url']);
            }
          }
        }

        return Waypoint(
          id: data['id'],
          hikeId: data['hike_id'],
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          latitude: data['latitude']?.toDouble() ?? 0.0,
          longitude: data['longitude']?.toDouble() ?? 0.0,
          orderIndex: data['order_index'] ?? 0,
          images: images,
          isVisited: data['is_visited'] ?? false,
        );
      }).toList();
    } catch (e) {
      print('Fehler beim Laden der Wegpunkte: $e');
      rethrow;
    }
  }

  Future<void> markWaypointAsVisited(int waypointId) async {
    try {
      await _backendApiService.client
          .from('waypoints')
          .update({'is_visited': true})
          .eq('id', waypointId);
    } catch (e) {
      print('Fehler beim Markieren des Wegpunkts als besucht: $e');
      rethrow;
    }
  }
} 