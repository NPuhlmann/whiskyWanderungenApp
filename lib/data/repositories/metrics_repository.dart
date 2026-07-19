import '../services/admin/admin_service.dart';

/// Repository für Admin-Kennzahlen (ADR-0004).
///
/// Pure pass-through to [AdminService]; the query logic stays in the service.
///
/// ponytail: until #84 this also held a DashboardMetricsService, but its two
/// forwarders were only ever called by DashboardProvider, which went with the
/// duplicate dashboard. That leaves the service itself without a consumer —
/// tearing it down belongs to #114.
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
