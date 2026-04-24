import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DashboardMetricsService {
  final SupabaseClient _client;

  DashboardMetricsService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  // Revenue Metrics
  Future<double> getDailyRevenue() async {
    try {
      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T')[0];
      final tomorrowStr = today
          .add(Duration(days: 1))
          .toIso8601String()
          .split('T')[0];

      final response = await _client
          .from('orders')
          .select('total_amount')
          .gte('created_at', '$todayStr 00:00:00')
          .lt('created_at', '$tomorrowStr 00:00:00')
          .eq('status', 'completed');

      double total = 0.0;
      for (final order in response) {
        total += (order['total_amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      log('Error getting daily revenue: $e');
      rethrow;
    }
  }

  Future<double> getWeeklyRevenue() async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartStr = weekStart.toIso8601String().split('T')[0];

      final response = await _client
          .from('orders')
          .select('total_amount')
          .gte('created_at', '$weekStartStr 00:00:00')
          .eq('status', 'completed');

      double total = 0.0;
      for (final order in response) {
        total += (order['total_amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      log('Error getting weekly revenue: $e');
      rethrow;
    }
  }

  Future<double> getMonthlyRevenue() async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthStartStr = monthStart.toIso8601String().split('T')[0];

      final response = await _client
          .from('orders')
          .select('total_amount')
          .gte('created_at', '$monthStartStr 00:00:00')
          .eq('status', 'completed');

      double total = 0.0;
      for (final order in response) {
        total += (order['total_amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      log('Error getting monthly revenue: $e');
      rethrow;
    }
  }

  // Order Metrics
  Future<int> getActiveOrdersByStatus(String status) async {
    try {
      final response = await _client
          .from('orders')
          .select('id')
          .eq('status', status);

      return response.length;
    } catch (e) {
      log('Error getting active orders by status $status: $e');
      rethrow;
    }
  }

  Future<int> getTotalActiveOrders() async {
    try {
      final response = await _client.from('orders').select('id').inFilter(
        'status',
        ['pending', 'processing', 'shipped'],
      );

      return response.length;
    } catch (e) {
      log('Error getting total active orders: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 10}) async {
    try {
      final response = await _client
          .from('orders')
          .select('''
            id,
            customer_name,
            total_amount,
            status,
            created_at,
            hikes!inner(name)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      // Transform the data to flatten hike name
      return response.map<Map<String, dynamic>>((order) {
        final transformed = Map<String, dynamic>.from(order);
        if (order['hikes'] != null && order['hikes']['name'] != null) {
          transformed['hike_name'] = order['hikes']['name'];
        }
        transformed.remove('hikes');
        return transformed;
      }).toList();
    } catch (e) {
      log('Error getting recent orders: $e');
      rethrow;
    }
  }

  // Route Metrics
  Future<int> getSoldRoutesToday() async {
    try {
      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T')[0];
      final tomorrowStr = today
          .add(Duration(days: 1))
          .toIso8601String()
          .split('T')[0];

      final response = await _client
          .from('orders')
          .select('id')
          .gte('created_at', '$todayStr 00:00:00')
          .lt('created_at', '$tomorrowStr 00:00:00')
          .eq('status', 'completed');

      return response.length;
    } catch (e) {
      log('Error getting sold routes today: $e');
      rethrow;
    }
  }

  Future<int> getSoldRoutesThisWeek() async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartStr = weekStart.toIso8601String().split('T')[0];

      final response = await _client
          .from('orders')
          .select('id')
          .gte('created_at', '$weekStartStr 00:00:00')
          .eq('status', 'completed');

      return response.length;
    } catch (e) {
      log('Error getting sold routes this week: $e');
      rethrow;
    }
  }

  Future<int> getSoldRoutesThisMonth() async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthStartStr = monthStart.toIso8601String().split('T')[0];

      final response = await _client
          .from('orders')
          .select('id')
          .gte('created_at', '$monthStartStr 00:00:00')
          .eq('status', 'completed');

      return response.length;
    } catch (e) {
      log('Error getting sold routes this month: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMostPopularRoutes({
    int limit = 5,
  }) async {
    try {
      final response = await _client.rpc(
        'get_popular_routes',
        params: {'route_limit': limit},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error getting most popular routes: $e');
      // Fallback implementation if RPC function doesn't exist
      try {
        final response = await _client
            .from('orders')
            .select('''
              hike_id,
              hikes!inner(name),
              count(*)
            ''')
            .eq('status', 'completed');

        // Group by hike and count
        final Map<int, Map<String, dynamic>> hikeStats = {};
        for (final order in response) {
          final hikeId = order['hike_id'] as int;
          if (!hikeStats.containsKey(hikeId)) {
            hikeStats[hikeId] = {
              'hike_id': hikeId,
              'hike_name': order['hikes']['name'],
              'count': 0,
            };
          }
          hikeStats[hikeId]!['count'] =
              (hikeStats[hikeId]!['count'] as int) + 1;
        }

        final sortedStats = hikeStats.values.toList()
          ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

        return sortedStats.take(limit).toList();
      } catch (fallbackError) {
        log('Fallback also failed: $fallbackError');
        rethrow;
      }
    }
  }

  // Customer Metrics
  Future<double> getAverageCustomerRating() async {
    try {
      final response = await _client.from('reviews').select('rating');

      if (response.isEmpty) return 0.0;

      double total = 0.0;
      for (final review in response) {
        total += (review['rating'] as num).toDouble();
      }

      return total / response.length;
    } catch (e) {
      log('Error getting average customer rating: $e');
      rethrow;
    }
  }

  // Comprehensive Dashboard Metrics
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    try {
      final futures = await Future.wait([
        getDailyRevenue(),
        getWeeklyRevenue(),
        getMonthlyRevenue(),
        getTotalActiveOrders(),
        getActiveOrdersByStatus('pending'),
        getActiveOrdersByStatus('processing'),
        getActiveOrdersByStatus('shipped'),
        getSoldRoutesToday(),
        getSoldRoutesThisWeek(),
        getSoldRoutesThisMonth(),
        getAverageCustomerRating(),
        getRecentOrders(),
        getMostPopularRoutes(),
      ]);

      return {
        'dailyRevenue': futures[0],
        'weeklyRevenue': futures[1],
        'monthlyRevenue': futures[2],
        'totalActiveOrders': futures[3],
        'pendingOrders': futures[4],
        'processingOrders': futures[5],
        'shippedOrders': futures[6],
        'soldRoutesToday': futures[7],
        'soldRoutesThisWeek': futures[8],
        'soldRoutesThisMonth': futures[9],
        'avgCustomerRating': futures[10],
        'recentOrders': futures[11],
        'popularRoutes': futures[12],
      };
    } catch (e) {
      log('Error getting dashboard metrics: $e');
      rethrow;
    }
  }

  // Utility Methods
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    return formatter.format(amount);
  }

  String formatPercentage(double value) {
    final formatter = NumberFormat.percentPattern('de_DE');
    return formatter.format(value);
  }

  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}
