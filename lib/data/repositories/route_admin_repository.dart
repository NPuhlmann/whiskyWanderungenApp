import 'dart:typed_data';

import '../services/admin/route_management_service.dart';

/// Repository für die Routenverwaltung im Admin-Bereich (ADR-0004).
///
/// Reiner Pass-through auf [RouteManagementService]; Query-, Validierungs-
/// und Geometrielogik bleiben dort.
class RouteAdminRepository {
  final RouteManagementService _service;

  RouteAdminRepository(this._service);

  Future<List<Map<String, dynamic>>> getAllRoutesForAdmin() =>
      _service.getAllRoutesForAdmin();

  Future<Map<String, dynamic>> getRouteById(int routeId) =>
      _service.getRouteById(routeId);

  Future<Map<String, dynamic>> createRoute(Map<String, dynamic> routeData) =>
      _service.createRoute(routeData);

  Future<Map<String, dynamic>> updateRoute(
    int routeId,
    Map<String, dynamic> updateData,
  ) => _service.updateRoute(routeId, updateData);

  Future<void> deleteRoute(int routeId) => _service.deleteRoute(routeId);

  Future<List<Map<String, dynamic>>> getRouteWaypoints(int routeId) =>
      _service.getRouteWaypoints(routeId);

  Future<Map<String, dynamic>> addWaypointToRoute(
    int routeId,
    Map<String, dynamic> waypointData,
  ) => _service.addWaypointToRoute(routeId, waypointData);

  Future<Map<String, dynamic>> updateWaypoint(
    int waypointId,
    Map<String, dynamic> updateData,
  ) => _service.updateWaypoint(waypointId, updateData);

  Future<void> updateWaypointOrder(
    int routeId,
    List<Map<String, dynamic>> newOrder,
  ) => _service.updateWaypointOrder(routeId, newOrder);

  Future<void> removeWaypointFromRoute(int routeId, int waypointId) =>
      _service.removeWaypointFromRoute(routeId, waypointId);

  Future<String> uploadRouteImage(
    int routeId,
    Uint8List imageBytes,
    String fileName,
  ) => _service.uploadRouteImage(routeId, imageBytes, fileName);

  Future<void> deleteRouteImage(int routeId, String fileName) =>
      _service.deleteRouteImage(routeId, fileName);

  Future<String> uploadWaypointImage(
    int waypointId,
    Uint8List imageBytes,
    String fileName,
  ) => _service.uploadWaypointImage(waypointId, imageBytes, fileName);

  bool validateRouteData(Map<String, dynamic> routeData) =>
      _service.validateRouteData(routeData);

  bool validateWaypointData(Map<String, dynamic> waypointData) =>
      _service.validateWaypointData(waypointData);

  Future<double> calculateRouteDistance(int routeId) =>
      _service.calculateRouteDistance(routeId);

  Future<String> generateRoutePreviewUrl(int routeId) =>
      _service.generateRoutePreviewUrl(routeId);
}
