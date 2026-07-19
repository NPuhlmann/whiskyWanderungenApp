import '../../domain/models/commission.dart';
import '../services/commission/commission_service.dart';

/// Repository für Provisionen (ADR-0004).
///
/// Bewusst ein reiner Pass-through auf [CommissionService] — die Query-Logik
/// bleibt im Service, das Repository verschiebt nur die Abhängigkeitskante,
/// damit Provider und Widgets keinen Supabase-Service mehr halten.
class CommissionRepository {
  final CommissionService _service;

  CommissionRepository(this._service);

  Future<List<Commission>> getCommissionsForCompany(String companyId) =>
      _service.getCommissionsForCompany(companyId);

  Future<Commission?> getCommissionByOrderId(String orderId) =>
      _service.getCommissionByOrderId(orderId);

  Future<List<Commission>> getCommissionsForDateRange(
    String companyId,
    DateTime startDate,
    DateTime endDate,
  ) => _service.getCommissionsForDateRange(companyId, startDate, endDate);

  Future<List<Commission>> getOverdueCommissions(String companyId) =>
      _service.getOverdueCommissions(companyId);

  Future<Map<String, dynamic>> getCommissionStatistics(String companyId) =>
      _service.getCommissionStatistics(companyId);

  Future<Map<int, Map<String, dynamic>>> getCommissionSummaryByHike(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
  }) => _service.getCommissionSummaryByHike(
    companyId,
    startDate: startDate,
    endDate: endDate,
  );

  Future<Commission> updateCommissionStatus(
    int commissionId,
    CommissionStatus status, {
    String? notes,
  }) => _service.updateCommissionStatus(commissionId, status, notes: notes);
}
