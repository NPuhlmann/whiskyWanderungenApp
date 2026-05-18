import 'package:flutter/foundation.dart';

import '../../domain/models/analytics/customer_insights.dart';
import '../../domain/models/analytics/route_performance.dart';
import '../../domain/models/analytics/sales_statistics.dart';
import '../services/analytics/customer_analytics_service.dart';
import '../services/analytics/sales_analytics_service.dart';

/// State-Management für `/admin/analytics`.
///
/// Bündelt Sales- und Customer-Analytics in einem Date-Range-Filter. Die
/// Services kapseln Supabase; der Provider hält Zustand, lädt parallel und
/// stellt Loading-/Fehler-Flags zur Verfügung.
class AnalyticsProvider extends ChangeNotifier {
  final SalesAnalyticsService _sales;
  final CustomerAnalyticsService _customer;

  AnalyticsProvider({
    required SalesAnalyticsService salesService,
    required CustomerAnalyticsService customerService,
    DateTime? initialStart,
    DateTime? initialEnd,
  })  : _sales = salesService,
        _customer = customerService {
    final now = DateTime.now();
    _endDate = initialEnd ?? DateTime(now.year, now.month, now.day, 23, 59, 59);
    _startDate = initialStart ?? _endDate.subtract(const Duration(days: 30));
  }

  late DateTime _startDate;
  late DateTime _endDate;
  String? _companyId;

  SalesStatistics _sales_ = SalesStatistics.empty();
  CustomerInsights _insights = CustomerInsights.empty();
  List<RoutePerformance> _topRoutes = const [];
  Map<String, int> _segmentation = const {'high': 0, 'medium': 0, 'low': 0};
  int _churnRisk = 0;

  bool _isLoading = false;
  String? _error;

  // ---------------------------------------------------------------------------
  // Getter
  // ---------------------------------------------------------------------------

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  String? get companyId => _companyId;

  SalesStatistics get sales => _sales_;
  CustomerInsights get customerInsights => _insights;
  List<RoutePerformance> get topRoutes => _topRoutes;
  Map<String, int> get segmentation => _segmentation;
  int get churnRisk => _churnRisk;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // ---------------------------------------------------------------------------
  // Aktionen
  // ---------------------------------------------------------------------------

  Future<void> setDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _startDate = startDate;
    _endDate = endDate;
    await load();
  }

  Future<void> setCompanyId(String? companyId) async {
    if (_companyId == companyId) return;
    _companyId = companyId;
    await load();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _sales.getSalesStatistics(
          startDate: _startDate,
          endDate: _endDate,
          companyId: _companyId,
        ),
        _customer.getCustomerInsights(
          startDate: _startDate,
          endDate: _endDate,
          companyId: _companyId,
        ),
        _sales.getTopRoutes(limit: 5),
        _customer.getCustomerSegmentation(),
        _customer.getChurnRiskCount(),
      ]);
      _sales_ = results[0] as SalesStatistics;
      _insights = results[1] as CustomerInsights;
      _topRoutes = results[2] as List<RoutePerformance>;
      _segmentation = results[3] as Map<String, int>;
      _churnRisk = results[4] as int;
    } catch (e) {
      _error = 'Analytics konnten nicht geladen werden: $e';
      _sales_ = SalesStatistics.empty();
      _insights = CustomerInsights.empty();
      _topRoutes = const [];
      _segmentation = const {'high': 0, 'medium': 0, 'low': 0};
      _churnRisk = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
