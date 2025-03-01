import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/waypoint.dart';
import '../services/database/backend_api.dart';

class WaypointRepository {
  final BackendApiService _backendApiService;

  WaypointRepository(this._backendApiService);

  Future<List<Waypoint>> getWaypointsForHike(int hikeId) async {
    try {
      // Zuerst die Verknüpfungen zwischen Hike und Waypoints abrufen
      final response = await _backendApiService.client
          .from('hikes_waypoints')
          .select('waypoint_id')
          .eq('hike_id', hikeId);
      
      final List<dynamic> waypointLinks = response;
      if (waypointLinks.isEmpty) {
        return [];
      }

      // Extrahiere die Waypoint-IDs
      final List<int> waypointIds = [];
      for (final element in waypointLinks) {
        if (element['waypoint_id'] != null) {
          waypointIds.add(int.parse(element['waypoint_id'].toString()));
        }
      }
      
      if (waypointIds.isEmpty) {
        return [];
      }

      // Hole die Wegpunkte für die IDs
      List<Waypoint> waypoints = [];
      for (final waypointId in waypointIds) {
        try {
          final waypointResponse = await _backendApiService.client
              .from('waypoints')
              .select()
              .eq('id', waypointId);
          
          final List<dynamic> waypointDataList = waypointResponse;
          if (waypointDataList.isNotEmpty) {
            final waypointData = waypointDataList.first;
            
            // Koordinaten aus dem location-Feld extrahieren
            double latitude = 0.0;
            double longitude = 0.0;
            if (waypointData['location'] != null) {
              final locationParts = waypointData['location'].toString().split(',');
              if (locationParts.length == 2) {
                try {
                  latitude = double.parse(locationParts[0]);
                  longitude = double.parse(locationParts[1]);
                } catch (e) {
                  print('Fehler beim Parsen der Koordinaten: $e');
                  // Verwende Standardwerte, wenn das Parsen fehlschlägt
                }
              }
            }
            
            // Hole die Bilder für den Wegpunkt aus der hike_images-Tabelle
            List<String> images = [];
            try {
              final imagesResponse = await _backendApiService.client
                  .from('hike_images')
                  .select('image_url')
                  .eq('hike_id', hikeId);
                  
              for (final image in imagesResponse) {
                if (image['image_url'] != null) {
                  images.add(image['image_url']);
                }
              }
            } catch (e) {
              print('Fehler beim Laden der Bilder: $e');
              // Verwende eine leere Liste, wenn das Laden der Bilder fehlschlägt
            }
            
            // Waypoint erstellen und zur Liste hinzufügen
            waypoints.add(Waypoint(
              id: waypointId,
              hikeId: hikeId,
              name: waypointData['name'] ?? '',
              description: waypointData['description'] ?? '',
              latitude: latitude,
              longitude: longitude,
              orderIndex: waypointData['order_index'] ?? 0,
              images: images,
              isVisited: waypointData['is_visited'] ?? false,
            ));
          }
        } catch (e) {
          print('Fehler beim Laden des Wegpunkts: $e');
          continue;
        }
      }
      
      return waypoints;
    } catch (e) {
      developer.log('Fehler beim Laden der Wegpunkte - getWaypointsForHike: $e');
      // Immer eine leere Liste zurückgeben, um null-Werte zu vermeiden
      return [];
    }
  }

  Future<void> markWaypointAsVisited(int waypointId) async {
    try {
      await _backendApiService.client
          .from('waypoints')
          .update({'is_visited': true})
          .eq('id', waypointId);
    } catch (e) {
      developer.log('Fehler beim Markieren des Wegpunkts als besucht: $e');
      rethrow;
    }
  }
} 