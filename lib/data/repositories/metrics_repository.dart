import '../services/admin/admin_service.dart';
import '../services/admin/dashboard_metrics_service.dart';

/// Repository für Admin-Kennzahlen (ADR-0004).
///
/// Fasst [AdminService] und [DashboardMetricsService] hinter einer Kante
/// zusammen — beide fragen dieselben Umsatz-Tabellen ab, zwei Repositories
/// darüber wären zwei Wahrheiten. Reiner Pass-through: die Query-Logik
/// bleibt in den Services.
class MetricsRepository {
  final AdminService _adminService;
  final DashboardMetricsService _dashboardService;

  MetricsRepository(this._adminService, this._dashboardService);

  // --- AdminProvider ---

  Future<Map<String, dynamic>> getDashboardKPIs() =>
      _adminService.getDashboardKPIs();

  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 10}) =>
      _adminService.getRecentOrders(limit: limit);

  Future<List<Map<String, dynamic>>> getRevenueTrend({int days = 30}) =>
      _adminService.getRevenueTrend(days: days);

  Future<List<Map<String, dynamic>>> getTopRoutes({int limit = 5}) =>
      _adminService.getTopRoutes(limit: limit);

  // --- DashboardProvider ---

  Future<Map<String, dynamic>> getDashboardMetrics() =>
      _dashboardService.getDashboardMetrics();

  /// Reine Formatierung, kein Datenzugriff — liegt hier nur, damit der
  /// DashboardProvider nicht zusätzlich den Service halten muss.
  String formatCurrency(double amount) =>
      _dashboardService.formatCurrency(amount);
}
