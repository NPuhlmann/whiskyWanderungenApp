import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/domain/models/analytics/sales_statistics.dart';
import 'package:whisky_hikes/domain/models/analytics/route_performance.dart';

/// Service for sales analytics and reporting
///
/// Provides comprehensive sales analytics including:
/// - Sales statistics aggregation (revenue, orders, trends)
/// - Route performance metrics (conversion, ratings, sales)
/// - Top performing routes analysis
class SalesAnalyticsService {
  final SupabaseClient _client;

  SalesAnalyticsService({required SupabaseClient client}) : _client = client;

  /// Get comprehensive sales statistics for a date range
  ///
  /// Aggregates order data to provide insights into:
  /// - Total revenue and order counts
  /// - Revenue and orders grouped by route
  /// - Daily revenue and order trends
  ///
  /// Optionally filters by [companyId] for multi-company setups
  Future<SalesStatistics> getSalesStatistics({
    required DateTime startDate,
    required DateTime endDate,
    String? companyId,
  }) async {
    try {
      // Build query
      var query = _client
          .from('orders')
          .select()
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      // Add company filter if provided
      if (companyId != null) {
        query = query.eq('company_id', companyId);
      }

      // Fetch orders
      final response = await query;
      final orders = response as List<dynamic>;

      // Return empty statistics if no orders
      if (orders.isEmpty) {
        return SalesStatistics.empty();
      }

      // Aggregate data
      int totalOrders = orders.length;
      double totalRevenue = 0.0;

      Map<String, int> ordersByRoute = {};
      Map<String, double> revenueByRoute = {};
      Map<String, int> ordersByDate = {};
      Map<String, double> revenueByDate = {};

      for (var order in orders) {
        final amount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
        totalRevenue += amount;

        // Group by route
        final routeId = order['hike_id'].toString();
        ordersByRoute[routeId] = (ordersByRoute[routeId] ?? 0) + 1;
        revenueByRoute[routeId] = (revenueByRoute[routeId] ?? 0.0) + amount;

        // Group by date (normalize to day)
        final createdAt = DateTime.parse(order['created_at'] as String);
        final dateKey =
            '${createdAt.year.toString().padLeft(4, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
        ordersByDate[dateKey] = (ordersByDate[dateKey] ?? 0) + 1;
        revenueByDate[dateKey] = (revenueByDate[dateKey] ?? 0.0) + amount;
      }

      final averageOrderValue =
          totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

      return SalesStatistics(
        totalOrders: totalOrders,
        totalRevenue: totalRevenue,
        averageOrderValue: averageOrderValue,
        ordersByRoute: ordersByRoute,
        revenueByRoute: revenueByRoute,
        ordersByDate: ordersByDate,
        revenueByDate: revenueByDate,
      );
    } catch (e) {
      log('Error getting sales statistics: $e');
      rethrow;
    }
  }

  /// Get performance metrics for a specific route
  ///
  /// Calculates comprehensive metrics including:
  /// - Sales volume and revenue
  /// - Customer ratings and reviews
  /// - Conversion rate (views to purchases)
  /// - Monthly sales trends
  Future<RoutePerformance> getRoutePerformance(int routeId) async {
    try {
      // Fetch orders for this route
      final ordersResponse = await _client
          .from('orders')
          .select()
          .eq('hike_id', routeId);

      final orders = ordersResponse as List<dynamic>;

      // Fetch route name
      final hikeResponse = await _client
          .from('hikes')
          .select('id, name')
          .eq('id', routeId)
          .single();

      final routeName = hikeResponse['name'] as String;

      // Calculate sales metrics
      final totalSales = orders.length;
      double totalRevenue = 0.0;
      Map<String, int> salesByMonth = {};

      for (var order in orders) {
        final amount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
        totalRevenue += amount;

        // Group by month
        final createdAt = DateTime.parse(order['created_at'] as String);
        final monthKey =
            '${createdAt.year.toString().padLeft(4, '0')}-${createdAt.month.toString().padLeft(2, '0')}';
        salesByMonth[monthKey] = (salesByMonth[monthKey] ?? 0) + 1;
      }

      // Fetch reviews
      final reviewsResponse = await _client
          .from('reviews')
          .select('rating')
          .eq('hike_id', routeId);

      final reviews = reviewsResponse as List<dynamic>;
      final reviewCount = reviews.length;

      double averageRating = 0.0;
      if (reviewCount > 0) {
        final totalRating = reviews.fold<double>(
          0.0,
          (sum, review) => sum + ((review['rating'] as num?)?.toDouble() ?? 0.0),
        );
        averageRating = totalRating / reviewCount;
      }

      // Fetch view count from analytics
      // TODO: Implement analytics_events table and tracking
      // For now, estimate views based on orders (approximate 4:1 ratio)
      int totalViews = totalSales * 4;

      // Calculate conversion rate
      final conversionRate =
          totalViews > 0 ? totalSales / totalViews : 0.0;

      return RoutePerformance(
        routeId: routeId,
        routeName: routeName,
        totalSales: totalSales,
        totalRevenue: totalRevenue,
        averageRating: averageRating,
        reviewCount: reviewCount,
        conversionRate: conversionRate,
        totalViews: totalViews,
        salesByMonth: salesByMonth,
      );
    } catch (e) {
      log('Error getting route performance for route $routeId: $e');
      rethrow;
    }
  }

  /// Get top performing routes
  ///
  /// Returns routes sorted by revenue (highest first)
  /// Limited to [limit] results (default 10)
  Future<List<RoutePerformance>> getTopRoutes({int limit = 10}) async {
    try {
      // Fetch all orders
      final ordersResponse = await _client.from('orders').select();
      final orders = ordersResponse as List<dynamic>;

      // Group orders by route
      Map<int, List<dynamic>> ordersByRoute = {};
      for (var order in orders) {
        final routeId = order['hike_id'] as int;
        ordersByRoute.putIfAbsent(routeId, () => []).add(order);
      }

      // Calculate performance for each route
      List<RoutePerformance> performances = [];
      for (var routeId in ordersByRoute.keys) {
        try {
          final performance = await getRoutePerformance(routeId);
          performances.add(performance);
        } catch (e) {
          log('Error getting performance for route $routeId: $e');
          // Skip routes that fail
          continue;
        }
      }

      // Sort by revenue (highest first) and limit
      performances.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
      return performances.take(limit).toList();
    } catch (e) {
      log('Error getting top routes: $e');
      rethrow;
    }
  }
}
