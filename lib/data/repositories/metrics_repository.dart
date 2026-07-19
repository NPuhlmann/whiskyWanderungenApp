import '../services/admin/admin_service.dart';

/// Repository für Admin-Kennzahlen (ADR-0004).
///
/// Reiner Pass-through auf [AdminService]: die Query-Logik bleibt im Service.
///
/// ponytail: hielt bis #84 zusätzlich einen DashboardMetricsService — dessen
/// beide Weiterleitungen bediente nur der DashboardProvider, der mit der
/// zweiten Dashboard-Implementierung entfallen ist. Der Service selbst ist
/// damit ohne Konsument; sein Abriss gehört zu #85/#114.
class MetricsRepository {
  final AdminService _adminService;

  MetricsRepository(this._adminService);

  // --- AdminProvider ---

  Future<Map<String, dynamic>> getDashboardKPIs() =>
      _adminService.getDashboardKPIs();

  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 10}) =>
      _adminService.getRecentOrders(limit: limit);

  Future<List<Map<String, dynamic>>> getRevenueTrend({int days = 30}) =>
      _adminService.getRevenueTrend(days: days);

  Future<List<Map<String, dynamic>>> getTopRoutes({int limit = 5}) =>
      _adminService.getTopRoutes(limit: limit);
}
