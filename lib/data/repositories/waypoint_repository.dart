import 'dart:developer' as developer;

import '../../domain/models/waypoint.dart';
import '../services/database/backend_api.dart';

class WaypointRepository {
  final BackendApiService _backendApiService;

  WaypointRepository(this._backendApiService);

  // Methode zum Abrufen aller Wegpunkte für eine Wanderung
  Future<List<Waypoint>> getWaypointsForHike(int hikeId) async {
    try {
      return await _backendApiService.getWaypointsForHike(hikeId);
    } catch (e) {
      developer.log('Fehler beim Abrufen der Wegpunkte: $e', error: e);
      throw Exception(
        'Fehler beim Abrufen der Wegpunkte für Wanderung $hikeId: $e',
      );
    }
  }

  // Methode zum Hinzufügen eines neuen Wegpunkts
  Future<void> addWaypoint(
    Waypoint waypoint,
    int hikeId, {
    int? orderIndex,
  }) async {
    try {
      await _backendApiService.addWaypoint(
        waypoint,
        hikeId,
        orderIndex: orderIndex,
      );
      developer.log(
        'Wegpunkt hinzugefügt: ${waypoint.id} mit order_index: ${orderIndex ?? waypoint.orderIndex}',
      );
    } catch (e) {
      developer.log('Fehler beim Hinzufügen des Wegpunkts: $e', error: e);
      throw Exception('Fehler beim Hinzufügen des Wegpunkts: $e');
    }
  }

  // Methode zum Aktualisieren eines Wegpunkts
  Future<void> updateWaypoint(Waypoint waypoint) async {
    try {
      await _backendApiService.updateWaypoint(waypoint);
      developer.log('Wegpunkt aktualisiert: ${waypoint.id}');
    } catch (e) {
      developer.log('Fehler beim Aktualisieren des Wegpunkts: $e', error: e);
      throw Exception('Fehler beim Aktualisieren des Wegpunkts: $e');
    }
  }

  // Methode zum Löschen eines Wegpunkts
  Future<void> deleteWaypoint(int waypointId, int hikeId) async {
    try {
      await _backendApiService.deleteWaypoint(waypointId, hikeId);
      developer.log('Wegpunkt gelöscht: $waypointId');
    } catch (e) {
      developer.log('Fehler beim Löschen des Wegpunkts: $e', error: e);
      throw Exception('Fehler beim Löschen des Wegpunkts: $e');
    }
  }

  // Methode zum Aktualisieren der Wegpunkt-Reihenfolge
  Future<void> updateWaypointOrder(
    int hikeId,
    int waypointId,
    int newOrderIndex,
  ) async {
    try {
      await _backendApiService.updateWaypointOrder(
        hikeId,
        waypointId,
        newOrderIndex,
      );
      developer.log(
        'Wegpunkt-Reihenfolge aktualisiert: waypoint $waypointId, neue Position: $newOrderIndex',
      );
    } catch (e) {
      developer.log(
        'Fehler beim Aktualisieren der Wegpunkt-Reihenfolge: $e',
        error: e,
      );
      throw Exception('Fehler beim Aktualisieren der Wegpunkt-Reihenfolge: $e');
    }
  }
}
