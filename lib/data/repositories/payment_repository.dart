import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/payment/multi_payment_service.dart';
import '../services/database/backend_api.dart';
import '../../domain/models/basic_order.dart';
import '../../domain/models/enhanced_order.dart';
import '../../domain/models/delivery_address.dart';
import '../../domain/models/payment_intent.dart' show PaymentMethodType;

/// Repository for handling payment-related database operations
/// Integrates with MultiPaymentService for multiple payment methods and Supabase for data persistence
class PaymentRepository {
  final SupabaseClient _supabaseClient;
  final MultiPaymentService _multiPaymentService;
  final BackendApiService _backendApiService;

  PaymentRepository({
    required SupabaseClient supabaseClient,
    MultiPaymentService? multiPaymentService,
    BackendApiService? backendApiService,
  }) : _supabaseClient = supabaseClient,
       _multiPaymentService =
           multiPaymentService ?? MultiPaymentService.instance,
       _backendApiService =
           backendApiService ?? BackendApiService(client: supabaseClient);

  /// Create a new order with order items
  Future<BasicOrder> createOrder({
    required int hikeId,
    required String userId,
    required double amount,
    required DeliveryType deliveryType,
    Map<String, dynamic>? deliveryAddress,
  }) async {
    try {
      // Validate input parameters
      _validateCreateOrderParams(hikeId, userId, amount);

      // Generate unique order number
      final orderNumber = _generateOrderNumber();

      dev.log('🔄 Creating order $orderNumber for user $userId...');

      // Create order record
      final orderData = {
        'order_number': orderNumber,
        'hike_id': hikeId,
        'user_id': userId,
        'total_amount': amount,
        'delivery_type': deliveryType.name,
        'status': OrderStatus.pending.name,
        'created_at': DateTime.now().toIso8601String(),
        'delivery_address': ?deliveryAddress,
      };

      final orderResponse = await _supabaseClient
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      // Create order item (for now, simple 1:1 mapping with hikes)
      final basePrice = deliveryType == DeliveryType.standardShipping
          ? amount -
                5.0 // Subtract shipping cost
          : amount;

      final orderItemData = {
        'order_id': orderResponse['id'],
        'hike_id': hikeId,
        'quantity': 1,
        'unit_price': basePrice,
        'total_price': basePrice,
      };

      await _supabaseClient.from('order_items').insert(orderItemData);

      dev.log('✅ Order $orderNumber created successfully');

      return BasicOrder.fromJson(orderResponse);
    } catch (e) {
      dev.log('❌ Error creating order: $e');
      if (e is PostgrestException) rethrow;
      if (e is ArgumentError) rethrow;
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get available payment methods for the device
  Future<List<PaymentMethodType>> getAvailablePaymentMethods() async {
    try {
      return await _multiPaymentService.getAvailablePaymentMethods();
    } catch (e) {
      dev.log('❌ Error getting available payment methods: $e');
      // Fallback to card only
      return [PaymentMethodType.card];
    }
  }

  /// Check if a specific payment method is available
  Future<bool> isPaymentMethodAvailable(PaymentMethodType paymentMethod) async {
    try {
      return await _multiPaymentService.isPaymentMethodAvailable(paymentMethod);
    } catch (e) {
      dev.log('❌ Error checking payment method availability: $e');
      return false;
    }
  }

  /// Get order by ID
  Future<BasicOrder> getOrderById(int orderId) async {
    try {
      final response = await _supabaseClient
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();

      return BasicOrder.fromJson(response);
    } catch (e) {
      dev.log('❌ Error fetching order $orderId: $e');
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch order: $e');
    }
  }

  /// Get all orders for a user
  Future<List<BasicOrder>> getUserOrders(String userId) async {
    try {
      final response = await _supabaseClient
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<BasicOrder>((json) => BasicOrder.fromJson(json))
          .toList();
    } catch (e) {
      dev.log('❌ Error fetching user orders: $e');
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  /// Update order status
  Future<BasicOrder> updateOrderStatus({
    required int orderId,
    required OrderStatus status,
    String? trackingNumber,
    DateTime? estimatedDelivery,
    String? paymentIntentId,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
        'tracking_number': ?trackingNumber,
        if (estimatedDelivery != null)
          'estimated_delivery': estimatedDelivery.toIso8601String(),
        'payment_intent_id': ?paymentIntentId,
      };

      final response = await _supabaseClient
          .from('orders')
          .update(updateData)
          .eq('id', orderId)
          .select()
          .single();

      dev.log('✅ Order $orderId status updated to ${status.name}');
      return BasicOrder.fromJson(response);
    } catch (e) {
      dev.log('❌ Error updating order status: $e');
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Generate unique order number
  String _generateOrderNumber() {
    final now = DateTime.now();
    final year = now.year;
    final timestamp = now.millisecondsSinceEpoch.toString().substring(
      8,
    ); // Last 5 digits
    return 'WH$year-$timestamp';
  }

  /// Validate create order parameters
  void _validateCreateOrderParams(int hikeId, String userId, double amount) {
    if (hikeId <= 0) {
      throw ArgumentError('Hike ID must be greater than 0');
    }

    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than 0');
    }

    if (amount > 999999.99) {
      throw ArgumentError('Amount exceeds maximum limit');
    }
  }

  // ================================
  // Enhanced Order Support
  // ================================

  /// Create enhanced order with shipping calculation
  Future<EnhancedOrder> createEnhancedOrder({
    required int hikeId,
    required String userId,
    required String companyId,
    required double baseAmount,
    required DeliveryAddress deliveryAddress,
    DeliveryType deliveryType = DeliveryType.standardShipping,
    String? customerEmail,
    String? customerPhone,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validate input parameters
      if (hikeId <= 0) throw ArgumentError('Hike ID must be greater than 0');
      if (userId.isEmpty) throw ArgumentError('User ID cannot be empty');
      if (companyId.isEmpty) throw ArgumentError('Company ID cannot be empty');
      if (baseAmount <= 0) {
        throw ArgumentError('Base amount must be greater than 0');
      }

      // Generate unique order number
      final orderNumber = _generateOrderNumber();

      dev.log('🔄 Creating enhanced order $orderNumber for user $userId...');

      // Create enhanced order with shipping calculation
      final enhancedOrder = await _backendApiService
          .createEnhancedOrderWithShipping(
            orderNumber: orderNumber,
            companyId: companyId,
            customerId: userId,
            hikeId: hikeId,
            baseOrderValue: baseAmount,
            deliveryAddress: deliveryAddress,
            deliveryType: deliveryType,
            customerEmail: customerEmail,
            customerPhone: customerPhone,
            metadata: metadata,
          );

      dev.log('✅ Enhanced order $orderNumber created successfully');
      return enhancedOrder;
    } catch (e) {
      dev.log('❌ Error creating enhanced order: $e');
      if (e is PostgrestException) rethrow;
      if (e is ArgumentError) rethrow;
      throw Exception('Failed to create enhanced order: $e');
    }
  }

  /// Get enhanced order by ID
  Future<EnhancedOrder?> getEnhancedOrderById(int orderId) async {
    try {
      return await _backendApiService.getEnhancedOrderById(orderId);
    } catch (e) {
      dev.log('❌ Error fetching enhanced order $orderId: $e');
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch enhanced order: $e');
    }
  }

  /// Get all enhanced orders for a customer
  Future<List<EnhancedOrder>> getCustomerEnhancedOrders({
    required String customerId,
    int limit = 50,
    int offset = 0,
    List<String>? statuses,
  }) async {
    try {
      return await _backendApiService.getCustomerEnhancedOrders(
        customerId: customerId,
        limit: limit,
        offset: offset,
        statuses: statuses,
      );
    } catch (e) {
      dev.log('❌ Error fetching customer enhanced orders: $e');
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to fetch customer enhanced orders: $e');
    }
  }

  /// Update enhanced order status
  Future<EnhancedOrder> updateEnhancedOrderStatus({
    required int orderId,
    required String newStatus,
    String? reason,
    String? trackingNumber,
    DateTime? estimatedDelivery,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      return await _backendApiService.updateEnhancedOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
        reason: reason,
        trackingNumber: trackingNumber,
        estimatedDelivery: estimatedDelivery,
        metadata: metadata,
      );
    } catch (e) {
      dev.log('❌ Error updating enhanced order status: $e');
      if (e is PostgrestException) rethrow;
      throw Exception('Failed to update enhanced order status: $e');
    }
  }

  /// Convert BasicOrder to EnhancedOrder
  Future<EnhancedOrder> convertToEnhancedOrder({
    required BasicOrder basicOrder,
    required String companyId,
    required DeliveryAddress deliveryAddress,
    String? customerEmail,
    String? customerPhone,
  }) async {
    try {
      return await _backendApiService.convertBasicToEnhancedOrder(
        basicOrder: basicOrder,
        companyId: companyId,
        deliveryAddress: deliveryAddress,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
      );
    } catch (e) {
      dev.log('❌ Error converting to enhanced order: $e');
      throw Exception('Failed to convert to enhanced order: $e');
    }
  }
}

/// Factory for creating PaymentRepository instances
class PaymentRepositoryFactory {
  static PaymentRepository create({
    SupabaseClient? supabaseClient,
    MultiPaymentService? multiPaymentService,
    BackendApiService? backendApiService,
  }) {
    final client = supabaseClient ?? Supabase.instance.client;
    return PaymentRepository(
      supabaseClient: client,
      multiPaymentService: multiPaymentService ?? MultiPaymentService.instance,
      backendApiService: backendApiService ?? BackendApiService(client: client),
    );
  }
}
