import 'dart:developer' as dev;
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/payment/stripe_service.dart';
import '../services/payment/multi_payment_service.dart';
import '../../domain/models/basic_order.dart';
import '../../domain/models/basic_payment_result.dart';
import '../../domain/models/payment_intent.dart';

/// Repository for handling payment-related database operations
/// Integrates with MultiPaymentService for multiple payment methods and Supabase for data persistence
class PaymentRepository {
  final SupabaseClient _supabaseClient;
  final StripeService _stripeService;
  final MultiPaymentService _multiPaymentService;

  PaymentRepository({
    required SupabaseClient supabaseClient,
    required StripeService stripeService,
    MultiPaymentService? multiPaymentService,
  })  : _supabaseClient = supabaseClient,
        _stripeService = stripeService,
        _multiPaymentService = multiPaymentService ?? MultiPaymentService.instance;

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
        if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      };

      final orderResponse = await _supabaseClient
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      // Create order item (for now, simple 1:1 mapping with hikes)
      final basePrice = deliveryType == DeliveryType.shipping 
          ? amount - 5.0  // Subtract shipping cost
          : amount;

      final orderItemData = {
        'order_id': orderResponse['id'],
        'hike_id': hikeId,
        'quantity': 1,
        'unit_price': basePrice,
        'total_price': basePrice,
      };

      await _supabaseClient
          .from('order_items')
          .insert(orderItemData);

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

  /// Process payment for an order using specified payment method
  Future<BasicPaymentResult> processPayment({
    required BasicOrder order,
    required PaymentMethodType paymentMethod,
    String? paymentMethodId, // For card payments
    Map<String, dynamic>? metadata,
  }) async {
    try {
      dev.log('🔄 Processing ${paymentMethod.name} payment for order ${order.orderNumber}...');

      // Use MultiPaymentService for all payment methods
      final paymentResult = await _multiPaymentService.processPayment(
        paymentMethod: paymentMethod,
        amount: order.totalAmount,
        currency: 'eur',
        metadata: {
          'order_id': order.id.toString(),
          'hike_id': order.hikeId.toString(),
          'delivery_type': order.deliveryType.name,
          'order_number': order.orderNumber,
          ...?metadata,
        },
      );

      // Store payment record in database
      await _createPaymentRecord(
        order: order,
        paymentMethod: paymentMethod,
        paymentResult: paymentResult,
      );

      // Update order status based on payment result
      if (paymentResult.isSuccess) {
        await updateOrderStatus(
          orderId: order.id,
          status: OrderStatus.confirmed,
          paymentIntentId: paymentResult.paymentIntentId,
        );
        dev.log('✅ ${paymentMethod.name} payment successful for order ${order.orderNumber}');
      } else if (paymentResult.requiresUserAction) {
        dev.log('🔐 ${paymentMethod.name} payment requires additional authentication');
      } else {
        dev.log('❌ ${paymentMethod.name} payment failed for order ${order.orderNumber}');
      }

      return paymentResult;

    } catch (e) {
      dev.log('❌ Error processing ${paymentMethod.name} payment: $e');
      // Return failed payment result instead of throwing
      return BasicPaymentResult.failure(
        error: 'Payment processing failed: ${e.toString()}',
        status: PaymentStatus.failed,
      );
    }
  }

  /// Process payment for an order using Stripe (legacy method - kept for backward compatibility)
  @Deprecated('Use processPayment with PaymentMethodType instead')
  Future<BasicPaymentResult> processStripePayment({
    required BasicOrder order,
    required String paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      dev.log('🔄 Processing payment for order ${order.orderNumber}...');

      // Create payment intent with Stripe
      final paymentIntent = await _stripeService.createPaymentIntent(
        amount: order.totalAmount,
        currency: 'eur',
        metadata: {
          'order_id': order.id.toString(),
          'hike_id': order.hikeId.toString(),
          'delivery_type': order.deliveryType.name,
          ...?metadata,
        },
      );

      // Confirm payment with provided payment method
      final paymentResult = await _stripeService.confirmPayment(
        clientSecret: paymentIntent.clientSecret,
        paymentMethodId: paymentMethodId,
        metadata: metadata,
      );

      // Store payment record in database
      await _createPaymentRecord(
        order: order,
        paymentIntent: paymentIntent,
        paymentResult: paymentResult,
      );

      // Update order status based on payment result
      if (paymentResult.isSuccess) {
        await updateOrderStatus(
          orderId: order.id,
          status: OrderStatus.confirmed,
          paymentIntentId: paymentIntent.id,
        );
        dev.log('✅ Payment successful for order ${order.orderNumber}');
      } else if (paymentResult.requiresUserAction) {
        dev.log('🔐 Payment requires additional authentication');
      } else {
        dev.log('❌ Payment failed for order ${order.orderNumber}');
      }

      return paymentResult;

    } catch (e) {
      dev.log('❌ Error processing payment: $e');
      // Return failed payment result instead of throwing
      return BasicPaymentResult.failure(
        error: 'Payment processing failed: ${e.toString()}',
        status: PaymentStatus.failed,
      );
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
        if (trackingNumber != null) 'tracking_number': trackingNumber,
        if (estimatedDelivery != null) 'estimated_delivery': estimatedDelivery.toIso8601String(),
        if (paymentIntentId != null) 'payment_intent_id': paymentIntentId,
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

  /// Create payment record in database for multi-payment methods
  Future<void> _createPaymentRecord({
    required BasicOrder order,
    required PaymentMethodType paymentMethod,
    required BasicPaymentResult paymentResult,
  }) async {
    try {
      final paymentData = {
        'order_id': order.id,
        'payment_intent_id': paymentResult.paymentIntentId ?? 'pi_${paymentMethod.name}_${DateTime.now().millisecondsSinceEpoch}',
        'client_secret': paymentResult.clientSecret,
        'amount': (order.totalAmount * 100).round(), // Convert to cents
        'currency': 'eur',
        'status': paymentResult.status?.name ?? 'pending',
        'payment_method': paymentMethod.name,
        if (paymentResult.errorMessage != null) 'failure_reason': paymentResult.errorMessage,
        if (paymentResult.metadata != null) 'metadata': paymentResult.metadata,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseClient
          .from('payments')
          .insert(paymentData);

      dev.log('✅ Payment record created for ${paymentMethod.name} payment: ${paymentData['payment_intent_id']}');

    } catch (e) {
      dev.log('⚠️ Warning: Failed to create payment record: $e');
      // Don't throw here - payment may have succeeded even if record creation failed
    }
  }

  /// Create payment record in database (legacy method for Stripe)
  @Deprecated('Use _createPaymentRecord with PaymentMethodType instead')
  Future<void> _createPaymentRecordLegacy({
    required BasicOrder order,
    required PaymentIntentResult paymentIntent,
    required BasicPaymentResult paymentResult,
  }) async {
    try {
      final paymentData = {
        'order_id': order.id,
        'payment_intent_id': paymentIntent.id,
        'client_secret': paymentIntent.clientSecret,
        'amount': paymentIntent.amount, // Already in cents
        'currency': paymentIntent.currency,
        'status': paymentResult.status?.name ?? 'pending',
        'payment_method': 'card', // Default to card, could be extended
        if (paymentResult.errorMessage != null) 'failure_reason': paymentResult.errorMessage,
        if (paymentResult.metadata != null) 'metadata': paymentResult.metadata,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseClient
          .from('payments')
          .insert(paymentData);

      dev.log('✅ Payment record created for payment intent ${paymentIntent.id}');

    } catch (e) {
      dev.log('⚠️ Warning: Failed to create payment record: $e');
      // Don't throw here - payment may have succeeded even if record creation failed
    }
  }

  /// Generate unique order number
  String _generateOrderNumber() {
    final now = DateTime.now();
    final year = now.year;
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8); // Last 5 digits
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
}

/// Factory for creating PaymentRepository instances
class PaymentRepositoryFactory {
  static PaymentRepository create({
    SupabaseClient? supabaseClient,
    StripeService? stripeService,
    MultiPaymentService? multiPaymentService,
  }) {
    return PaymentRepository(
      supabaseClient: supabaseClient ?? Supabase.instance.client,
      stripeService: stripeService ?? StripeService.instance,
      multiPaymentService: multiPaymentService ?? MultiPaymentService.instance,
    );
  }
}