import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/domain/models/analytics/customer_insights.dart';

/// Service for customer analytics and behavior analysis
///
/// Provides comprehensive customer insights including:
/// - Customer acquisition and retention metrics
/// - Repeat purchase behavior analysis
/// - Customer lifetime value calculations
/// - Geographic distribution analysis
class CustomerAnalyticsService {
  final SupabaseClient _client;

  CustomerAnalyticsService({required SupabaseClient client}) : _client = client;

  /// Get comprehensive customer insights for a date range
  ///
  /// Analyzes customer behavior to provide insights into:
  /// - New vs returning customers in the period
  /// - Repeat purchase rate
  /// - Average lifetime value
  /// - Geographic distribution
  /// - Order frequency patterns
  ///
  /// Optionally filters by [companyId] for multi-company setups
  Future<CustomerInsights> getCustomerInsights({
    required DateTime startDate,
    required DateTime endDate,
    String? companyId,
  }) async {
    try {
      // Fetch all orders to analyze customer behavior
      var ordersQuery = _client
          .from('orders')
          .select('user_id, total_amount, created_at');

      if (companyId != null) {
        ordersQuery = ordersQuery.eq('company_id', companyId);
      }

      final ordersResponse = await ordersQuery;
      final allOrders = ordersResponse as List<dynamic>;

      if (allOrders.isEmpty) {
        return CustomerInsights.empty();
      }

      // Fetch user profiles to get location data
      final profilesResponse = await _client
          .from('profiles')
          .select('id, location');
      final profiles = profilesResponse as List<dynamic>;

      // Create location lookup map
      Map<String, String?> userLocations = {};
      for (var profile in profiles) {
        userLocations[profile['id'] as String] = profile['location'] as String?;
      }

      // Aggregate customer data
      Map<String, List<dynamic>> ordersByCustomer = {};
      Map<String, double> lifetimeValueByCustomer = {};
      Map<String, DateTime> firstOrderByCustomer = {};

      for (var order in allOrders) {
        final userId = order['user_id'] as String;
        final amount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
        final createdAt = DateTime.parse(order['created_at'] as String);

        ordersByCustomer.putIfAbsent(userId, () => []).add(order);
        lifetimeValueByCustomer[userId] =
            (lifetimeValueByCustomer[userId] ?? 0.0) + amount;

        if (!firstOrderByCustomer.containsKey(userId) ||
            createdAt.isBefore(firstOrderByCustomer[userId]!)) {
          firstOrderByCustomer[userId] = createdAt;
        }
      }

      // Calculate metrics
      final totalCustomers = ordersByCustomer.length;
      int newCustomers = 0;
      int returningCustomers = 0;
      int customersWithRepeats = 0;
      double totalLifetimeValue = 0.0;

      Map<String, int> customersByLocation = {};
      Map<int, int> orderFrequencyDistribution = {};

      for (var userId in ordersByCustomer.keys) {
        final customerOrders = ordersByCustomer[userId]!;
        final orderCount = customerOrders.length;
        final firstOrderDate = firstOrderByCustomer[userId]!;
        final ltv = lifetimeValueByCustomer[userId]!;

        totalLifetimeValue += ltv;

        // Check if customer is new in this period
        final isNewInPeriod =
            firstOrderDate.isAfter(startDate.subtract(Duration(days: 1))) &&
            firstOrderDate.isBefore(endDate.add(Duration(days: 1)));

        if (isNewInPeriod) {
          newCustomers++;
        } else {
          returningCustomers++;
        }

        // Check if customer has repeat purchases
        if (orderCount > 1) {
          customersWithRepeats++;
        }

        // Aggregate by location
        final location = userLocations[userId];
        if (location != null && location.isNotEmpty) {
          customersByLocation[location] =
              (customersByLocation[location] ?? 0) + 1;
        }

        // Build frequency distribution
        orderFrequencyDistribution[orderCount] =
            (orderFrequencyDistribution[orderCount] ?? 0) + 1;
      }

      // Calculate rates
      final repeatPurchaseRate = totalCustomers > 0
          ? customersWithRepeats / totalCustomers
          : 0.0;

      final averageLifetimeValue = totalCustomers > 0
          ? totalLifetimeValue / totalCustomers
          : 0.0;

      return CustomerInsights(
        totalCustomers: totalCustomers,
        newCustomers: newCustomers,
        returningCustomers: returningCustomers,
        repeatPurchaseRate: repeatPurchaseRate,
        averageLifetimeValue: averageLifetimeValue,
        customersByLocation: customersByLocation,
        orderFrequencyDistribution: orderFrequencyDistribution,
      );
    } catch (e) {
      log('Error getting customer insights: $e');
      rethrow;
    }
  }

  /// Get customer segmentation by purchase behavior
  ///
  /// Returns customers grouped into segments:
  /// - High value (LTV > 500€)
  /// - Medium value (LTV 200-500€)
  /// - Low value (LTV < 200€)
  Future<Map<String, int>> getCustomerSegmentation() async {
    try {
      // Fetch all orders
      final ordersResponse = await _client
          .from('orders')
          .select('user_id, total_amount');
      final orders = ordersResponse as List<dynamic>;

      // Calculate LTV per customer
      Map<String, double> ltvByCustomer = {};
      for (var order in orders) {
        final userId = order['user_id'] as String;
        final amount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
        ltvByCustomer[userId] = (ltvByCustomer[userId] ?? 0.0) + amount;
      }

      // Segment customers
      int highValue = 0;
      int mediumValue = 0;
      int lowValue = 0;

      for (var ltv in ltvByCustomer.values) {
        if (ltv > 500.0) {
          highValue++;
        } else if (ltv >= 200.0) {
          mediumValue++;
        } else {
          lowValue++;
        }
      }

      return {'high': highValue, 'medium': mediumValue, 'low': lowValue};
    } catch (e) {
      log('Error getting customer segmentation: $e');
      rethrow;
    }
  }

  /// Get churn risk analysis
  ///
  /// Identifies customers who haven't ordered in the last [days] days
  Future<int> getChurnRiskCount({int days = 90}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      // Fetch all orders
      final ordersResponse = await _client
          .from('orders')
          .select('user_id, created_at');
      final orders = ordersResponse as List<dynamic>;

      // Find last order date per customer
      Map<String, DateTime> lastOrderByCustomer = {};
      for (var order in orders) {
        final userId = order['user_id'] as String;
        final createdAt = DateTime.parse(order['created_at'] as String);

        if (!lastOrderByCustomer.containsKey(userId) ||
            createdAt.isAfter(lastOrderByCustomer[userId]!)) {
          lastOrderByCustomer[userId] = createdAt;
        }
      }

      // Count customers at churn risk
      int churnRisk = 0;
      for (var lastOrderDate in lastOrderByCustomer.values) {
        if (lastOrderDate.isBefore(cutoffDate)) {
          churnRisk++;
        }
      }

      return churnRisk;
    } catch (e) {
      log('Error getting churn risk count: $e');
      rethrow;
    }
  }
}
