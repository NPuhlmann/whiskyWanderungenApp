import 'package:supabase_flutter/supabase_flutter.dart';

/// Service für Admin-Funktionalitäten und Dashboard-Daten
class AdminService {
  final SupabaseClient _client;

  AdminService({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;

  /// Lädt Dashboard-KPIs für den aktuellen Benutzer
  Future<Map<String, dynamic>> getDashboardKPIs() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Verkaufte Routen (diesen Monat)
      final monthlyRoutesResult = await _client
          .from('orders')
          .select('id, created_at')
          .filter('created_at', 'gte', startOfMonth.toIso8601String())
          .eq('status', 'delivered');

      // Umsatz (diesen Monat)
      final monthlyRevenueResult = await _client
          .from('orders')
          .select('total_amount, created_at')
          .filter('created_at', 'gte', startOfMonth.toIso8601String())
          .eq('status', 'delivered');

      // Aktive Bestellungen
      final activeOrdersResult = await _client
          .from('orders')
          .select('id, status')
          .filter('status', 'in', '(pending,confirmed,processing,shipped)');

      // Durchschnittliche Kundenbewertung
      final ratingResult = await _client
          .from('reviews')
          .select('rating');

      // Berechne KPIs
      final monthlyRoutes = monthlyRoutesResult.length;
      final monthlyRevenue = monthlyRevenueResult.fold<double>(
        0.0, 
        (sum, order) => sum + (order['total_amount'] as num)
      );
      final activeOrders = activeOrdersResult.length;
      
      double averageRating = 0.0;
      if (ratingResult.isNotEmpty) {
        final totalRating = ratingResult.fold<double>(
          0.0, 
          (sum, review) => sum + (review['rating'] as num)
        );
        averageRating = totalRating / ratingResult.length;
      }

      return {
        'monthlyRoutes': monthlyRoutes,
        'monthlyRevenue': monthlyRevenue,
        'activeOrders': activeOrders,
        'averageRating': averageRating,
        'weeklyRevenue': await _getWeeklyRevenue(startOfWeek),
        'dailyRevenue': await _getDailyRevenue(startOfDay),
      };
    } catch (e) {
      print('Fehler beim Laden der Dashboard-KPIs: $e');
      return {
        'monthlyRoutes': 0,
        'monthlyRevenue': 0.0,
        'activeOrders': 0,
        'averageRating': 0.0,
        'weeklyRevenue': 0.0,
        'dailyRevenue': 0.0,
      };
    }
  }

  /// Lädt wöchentlichen Umsatz
  Future<double> _getWeeklyRevenue(DateTime startOfWeek) async {
    try {
      final result = await _client
          .from('orders')
          .select('total_amount')
          .filter('created_at', 'gte', startOfWeek.toIso8601String())
          .eq('status', 'delivered');

      return result.fold<double>(
        0.0, 
        (sum, order) => sum + (order['total_amount'] as num)
      );
    } catch (e) {
      print('Fehler beim Laden des wöchentlichen Umsatzes: $e');
      return 0.0;
    }
  }

  /// Lädt täglichen Umsatz
  Future<double> _getDailyRevenue(DateTime startOfDay) async {
    try {
      final result = await _client
          .from('orders')
          .select('total_amount')
          .filter('created_at', 'gte', startOfDay.toIso8601String())
          .eq('status', 'delivered');

      return result.fold<double>(
        0.0, 
        (sum, order) => sum + (order['total_amount'] as num)
      );
    } catch (e) {
      print('Fehler beim Laden des täglichen Umsatzes: $e');
      return 0.0;
    }
  }

  /// Lädt aktuelle Bestellungen
  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 10}) async {
    try {
      final result = await _client
          .from('orders')
          .select('''
            id, 
            order_number, 
            total_amount, 
            status, 
            created_at,
            hikes!inner(name, thumbnail_image_url),
            profiles!inner(email, full_name)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      return result.map((order) => {
        'id': order['id'],
        'orderNumber': order['order_number'],
        'routeName': order['hikes']['name'],
        'amount': order['total_amount'],
        'status': order['status'],
        'customerName': order['profiles']['full_name'] ?? order['profiles']['email'],
        'createdAt': order['created_at'],
        'routeImage': order['hikes']['thumbnail_image_url'],
      }).toList();
    } catch (e) {
      print('Fehler beim Laden der aktuellen Bestellungen: $e');
      return [];
    }
  }

  /// Lädt Umsatz-Entwicklung der letzten 30 Tage
  Future<List<Map<String, dynamic>>> getRevenueTrend({int days = 30}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final result = await _client
          .from('orders')
          .select('total_amount, created_at')
          .filter('created_at', 'gte', startDate.toIso8601String())
          .filter('created_at', 'lte', endDate.toIso8601String())
          .eq('status', 'delivered')
          .order('created_at');

      // Gruppiere nach Tagen
      final Map<String, double> dailyRevenue = {};
      for (final order in result) {
        final date = DateTime.parse(order['created_at']).toIso8601String().split('T')[0];
        dailyRevenue[date] = (dailyRevenue[date] ?? 0.0) + (order['total_amount'] as num);
      }

      // Fülle fehlende Tage mit 0
      final List<Map<String, dynamic>> trend = [];
      for (int i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i)).toIso8601String().split('T')[0];
        trend.add({
          'date': date,
          'revenue': dailyRevenue[date] ?? 0.0,
        });
      }

      return trend;
    } catch (e) {
      print('Fehler beim Laden der Umsatz-Entwicklung: $e');
      return [];
    }
  }

  /// Lädt beliebteste Wanderrouten
  Future<List<Map<String, dynamic>>> getTopRoutes({int limit = 5}) async {
    try {
      final result = await _client
          .from('orders')
          .select('''
            hikes!inner(id, name, thumbnail_image_url, price),
            count
          ''')
          .eq('status', 'delivered')
          .order('count', ascending: false)
          .limit(limit);

      return result.map((route) => {
        'id': route['hikes']['id'],
        'name': route['hikes']['name'],
        'image': route['hikes']['thumbnail_image_url'],
        'price': route['hikes']['price'],
        'sales': route['count'],
      }).toList();
    } catch (e) {
      print('Fehler beim Laden der beliebtesten Routen: $e');
      return [];
    }
  }
}
