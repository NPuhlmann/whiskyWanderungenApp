import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service für die Verwaltung von Bestellungen im Admin-Bereich
class OrderManagementService {
  final SupabaseClient _client;

  OrderManagementService({SupabaseClient? client})
      : _client = client ?? _getDefaultClient();

  static SupabaseClient _getDefaultClient() {
    try {
      return Supabase.instance.client;
    } catch (e) {
      // For testing purposes, return a mock-friendly null that won't be used
      throw Exception('Supabase not initialized. Provide a client in constructor for testing.');
    }
  }

  // Valid order statuses
  static const List<String> _validStatuses = [
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  /// Lädt alle Bestellungen für Admin-Dashboard
  Future<List<Map<String, dynamic>>> getAllOrdersForAdmin() async {
    try {
      log('Loading all orders for admin...');

      final response = await _client
          .from('orders')
          .select('*')
          .order('created_at', ascending: false);

      log('Loaded ${response.length} orders');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error loading orders: $e');
      rethrow;
    }
  }

  /// Lädt eine spezifische Bestellung anhand der ID
  Future<Map<String, dynamic>> getOrderById(int orderId) async {
    try {
      log('Loading order with ID: $orderId');

      final response = await _client
          .from('orders')
          .select('*')
          .eq('id', orderId)
          .single();

      log('Loaded order: ${response['id']}');
      return response;
    } catch (e) {
      log('Error loading order $orderId: $e');
      rethrow;
    }
  }

  /// Erstellt eine neue Bestellung
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      log('Creating new order for user: ${orderData['user_id']}');

      // Validiere Bestelldaten
      if (!validateOrderData(orderData)) {
        throw Exception('Invalid order data');
      }

      final response = await _client
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      log('Created order with ID: ${response['id']}');
      return response;
    } catch (e) {
      log('Error creating order: $e');
      rethrow;
    }
  }

  /// Aktualisiert eine bestehende Bestellung
  Future<Map<String, dynamic>> updateOrder(int orderId, Map<String, dynamic> updateData) async {
    try {
      log('Updating order $orderId');

      // Validiere Update-Daten
      if (!validateUpdateData(updateData)) {
        throw Exception('Invalid update data');
      }

      final response = await _client
          .from('orders')
          .update(updateData)
          .eq('id', orderId)
          .select()
          .single();

      log('Updated order $orderId');
      return response;
    } catch (e) {
      log('Error updating order $orderId: $e');
      rethrow;
    }
  }

  /// Löscht eine Bestellung
  Future<void> deleteOrder(int orderId) async {
    try {
      log('Deleting order $orderId');

      await _client
          .from('orders')
          .delete()
          .eq('id', orderId);

      log('Deleted order $orderId');
    } catch (e) {
      log('Error deleting order $orderId: $e');
      rethrow;
    }
  }

  /// Aktualisiert den Status einer Bestellung
  Future<Map<String, dynamic>> updateOrderStatus(int orderId, String newStatus) async {
    try {
      log('Updating order $orderId status to: $newStatus');

      if (!validateOrderStatus(newStatus)) {
        throw Exception('Invalid order status: $newStatus');
      }

      final response = await _client
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId)
          .select()
          .single();

      log('Updated order $orderId status to $newStatus');
      return response;
    } catch (e) {
      log('Error updating order status: $e');
      rethrow;
    }
  }

  /// Lädt Bestellungen nach Status
  Future<List<Map<String, dynamic>>> getOrdersByStatus(String status) async {
    try {
      log('Loading orders with status: $status');

      final response = await _client
          .from('orders')
          .select('*')
          .eq('status', status)
          .order('created_at', ascending: false);

      log('Loaded ${response.length} orders with status $status');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error loading orders by status: $e');
      rethrow;
    }
  }

  /// Sucht Bestellungen nach verschiedenen Kriterien
  Future<List<Map<String, dynamic>>> searchOrders(String searchTerm) async {
    try {
      log('Searching orders with term: $searchTerm');

      final response = await _client
          .from('orders')
          .select('*')
          .ilike('id', '%$searchTerm%')
          .order('created_at', ascending: false);

      log('Found ${response.length} orders for search term: $searchTerm');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error searching orders: $e');
      rethrow;
    }
  }

  /// Lädt Bestellungen in einem Datumsbereich
  Future<List<Map<String, dynamic>>> getOrdersByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      log('Loading orders between ${startDate.toIso8601String()} and ${endDate.toIso8601String()}');

      final response = await _client
          .from('orders')
          .select('*')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      log('Loaded ${response.length} orders in date range');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error loading orders by date range: $e');
      rethrow;
    }
  }

  /// Lädt Bestellungen für einen bestimmten Benutzer
  Future<List<Map<String, dynamic>>> getOrdersByUser(String userId) async {
    try {
      log('Loading orders for user: $userId');

      final response = await _client
          .from('orders')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      log('Loaded ${response.length} orders for user $userId');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error loading orders for user: $e');
      rethrow;
    }
  }

  /// Berechnet Bestellstatistiken
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      log('Calculating order statistics...');

      final orders = await _client
          .from('orders')
          .select('*');

      final totalOrders = orders.length;
      final totalRevenue = orders.fold<double>(0.0, (sum, order) =>
          sum + (order['total_amount'] as num? ?? 0.0).toDouble());
      final averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

      final pendingOrders = orders.where((order) => order['status'] == 'pending').length;
      final completedOrders = orders.where((order) =>
          ['shipped', 'delivered'].contains(order['status'])).length;

      final stats = {
        'totalOrders': totalOrders,
        'totalRevenue': double.parse(totalRevenue.toStringAsFixed(2)),
        'averageOrderValue': double.parse(averageOrderValue.toStringAsFixed(2)),
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
      };

      log('Calculated order statistics: $stats');
      return stats;
    } catch (e) {
      log('Error calculating order statistics: $e');
      rethrow;
    }
  }

  /// Lädt die neuesten Bestellungen
  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 10}) async {
    try {
      log('Loading recent orders (limit: $limit)...');

      final response = await _client
          .from('orders')
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);

      log('Loaded ${response.length} recent orders');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error loading recent orders: $e');
      rethrow;
    }
  }

  /// Validiert Bestelldaten
  bool validateOrderData(Map<String, dynamic> orderData) {
    try {
      // Prüfe erforderliche Felder
      if (orderData['user_id'] == null || orderData['user_id'].toString().isEmpty) {
        log('Validation failed: user_id is required');
        return false;
      }

      if (orderData['hike_id'] == null) {
        log('Validation failed: hike_id is required');
        return false;
      }

      if (orderData['total_amount'] == null) {
        log('Validation failed: total_amount is required');
        return false;
      }

      // Convert to double for validation
      final amount = double.tryParse(orderData['total_amount'].toString()) ?? 0.0;
      if (amount <= 0) {
        log('Validation failed: total_amount must be greater than 0');
        return false;
      }

      // Prüfe Status falls vorhanden
      if (orderData.containsKey('status') && !validateOrderStatus(orderData['status'])) {
        log('Validation failed: invalid status');
        return false;
      }

      return true;
    } catch (e) {
      log('Error validating order data: $e');
      return false;
    }
  }

  /// Validiert Update-Daten
  bool validateUpdateData(Map<String, dynamic> updateData) {
    try {
      // Prüfe Status falls vorhanden
      if (updateData.containsKey('status') && !validateOrderStatus(updateData['status'])) {
        log('Validation failed: invalid status in update data');
        return false;
      }

      // Prüfe total_amount falls vorhanden
      if (updateData.containsKey('total_amount')) {
        if (updateData['total_amount'] == null) {
          log('Validation failed: total_amount cannot be null in update data');
          return false;
        }

        final amount = double.tryParse(updateData['total_amount'].toString()) ?? 0.0;
        if (amount <= 0) {
          log('Validation failed: total_amount must be greater than 0 in update data');
          return false;
        }
      }

      return true;
    } catch (e) {
      log('Error validating update data: $e');
      return false;
    }
  }

  /// Validiert Bestellstatus
  bool validateOrderStatus(String status) {
    return _validStatuses.contains(status);
  }

  /// Gibt die verfügbaren Bestellstatus zurück
  List<String> getValidStatuses() {
    return List.from(_validStatuses);
  }

  /// Prüft ob ein Status als "abgeschlossen" gilt
  bool isCompletedStatus(String status) {
    return ['shipped', 'delivered'].contains(status);
  }

  /// Prüft ob ein Status als "ausstehend" gilt
  bool isPendingStatus(String status) {
    return ['pending', 'confirmed', 'processing'].contains(status);
  }

  /// Prüft ob ein Status als "storniert" gilt
  bool isCancelledStatus(String status) {
    return status == 'cancelled';
  }
}