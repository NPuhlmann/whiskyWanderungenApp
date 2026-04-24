import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:whisky_hikes/data/services/admin/dashboard_metrics_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardMetricsService _metricsService;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _metrics = {};
  List<Map<String, dynamic>> _recentOrders = [];
  List<Map<String, dynamic>> _popularRoutes = [];

  DashboardProvider({DashboardMetricsService? metricsService})
    : _metricsService = metricsService ?? DashboardMetricsService();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get metrics => _metrics;
  List<Map<String, dynamic>> get recentOrders => _recentOrders;
  List<Map<String, dynamic>> get popularRoutes => _popularRoutes;

  // Revenue Metrics
  double get dailyRevenue =>
      (_metrics['dailyRevenue'] as num?)?.toDouble() ?? 0.0;
  double get weeklyRevenue =>
      (_metrics['weeklyRevenue'] as num?)?.toDouble() ?? 0.0;
  double get monthlyRevenue =>
      (_metrics['monthlyRevenue'] as num?)?.toDouble() ?? 0.0;

  String get formattedDailyRevenue =>
      _metricsService.formatCurrency(dailyRevenue);
  String get formattedWeeklyRevenue =>
      _metricsService.formatCurrency(weeklyRevenue);
  String get formattedMonthlyRevenue =>
      _metricsService.formatCurrency(monthlyRevenue);

  // Order Metrics
  int get totalActiveOrders => (_metrics['totalActiveOrders'] as int?) ?? 0;
  int get pendingOrders => (_metrics['pendingOrders'] as int?) ?? 0;
  int get processingOrders => (_metrics['processingOrders'] as int?) ?? 0;
  int get shippedOrders => (_metrics['shippedOrders'] as int?) ?? 0;

  // Route Sales Metrics
  int get soldRoutesToday => (_metrics['soldRoutesToday'] as int?) ?? 0;
  int get soldRoutesThisWeek => (_metrics['soldRoutesThisWeek'] as int?) ?? 0;
  int get soldRoutesThisMonth => (_metrics['soldRoutesThisMonth'] as int?) ?? 0;

  // Customer Rating
  double get averageCustomerRating =>
      (_metrics['avgCustomerRating'] as num?)?.toDouble() ?? 0.0;
  String get formattedRating => averageCustomerRating.toStringAsFixed(1);
  int get ratingStars => averageCustomerRating.round();

  // Growth Calculations
  double get dailyGrowthPercentage {
    if (weeklyRevenue == 0) return 0.0;
    final weeklyAverage = weeklyRevenue / 7;
    if (weeklyAverage == 0) return 0.0;
    return ((dailyRevenue - weeklyAverage) / weeklyAverage) * 100;
  }

  double get weeklyGrowthPercentage {
    if (monthlyRevenue == 0) return 0.0;
    final monthlyAverage = monthlyRevenue / 4; // Assuming 4 weeks per month
    if (monthlyAverage == 0) return 0.0;
    return ((weeklyRevenue - monthlyAverage) / monthlyAverage) * 100;
  }

  // Data Status Checks
  bool get hasRevenueData =>
      dailyRevenue > 0 || weeklyRevenue > 0 || monthlyRevenue > 0;
  bool get hasOrderData => totalActiveOrders > 0;
  bool get hasRecentOrders => _recentOrders.isNotEmpty;
  bool get hasPopularRoutes => _popularRoutes.isNotEmpty;

  // State Management
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Data Loading
  Future<void> loadDashboardData() async {
    setLoading(true);
    clearError();

    try {
      final metricsData = await _metricsService.getDashboardMetrics();

      _metrics = metricsData;
      _recentOrders = List<Map<String, dynamic>>.from(
        metricsData['recentOrders'] ?? [],
      );
      _popularRoutes = List<Map<String, dynamic>>.from(
        metricsData['popularRoutes'] ?? [],
      );
    } catch (e) {
      log('Error loading dashboard data: $e');
      setError('Failed to load dashboard data. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // Data Filtering
  List<Map<String, dynamic>> getOrdersByStatus(String status) {
    return _recentOrders.where((order) => order['status'] == status).toList();
  }

  // Quick Stats
  Map<String, dynamic> getQuickStats() {
    return {
      'totalRevenue': monthlyRevenue,
      'totalOrders': totalActiveOrders,
      'totalRoutesSold': soldRoutesThisMonth,
      'averageRating': averageCustomerRating,
      'dailyGrowth': dailyGrowthPercentage,
      'weeklyGrowth': weeklyGrowthPercentage,
    };
  }

  // Revenue Trend Data (for charts)
  List<Map<String, dynamic>> getRevenueTrendData() {
    return [
      {'period': 'Today', 'revenue': dailyRevenue},
      {'period': 'This Week', 'revenue': weeklyRevenue},
      {'period': 'This Month', 'revenue': monthlyRevenue},
    ];
  }

  // Order Status Distribution
  Map<String, int> getOrderStatusDistribution() {
    return {
      'pending': pendingOrders,
      'processing': processingOrders,
      'shipped': shippedOrders,
    };
  }

  // Popular Routes Summary
  List<Map<String, dynamic>> getTopRoutes({int limit = 5}) {
    return _popularRoutes.take(limit).toList();
  }

  // Recent Activity Summary
  List<Map<String, dynamic>> getRecentActivity({int limit = 5}) {
    return _recentOrders.take(limit).toList();
  }
}
