import 'dart:developer' as dev;
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../domain/models/basic_payment_result.dart';

/// Service for handling Stripe payments integration
class StripeService {
  static StripeService? _instance;
  static StripeService get instance => _instance ??= StripeService._internal();
  
  StripeService._internal();
  
  bool _isInitialized = false;
  String? _publishableKey;
  
  /// Initialize Stripe with publishable key
  Future<void> initialize([String? publishableKey]) async {
    try {
      // Use provided key or fallback to environment variable
      final key = publishableKey ?? dotenv.env['STRIPE_PUBLISHABLE_KEY_TEST'];
      
      if (key == null || key.isEmpty) {
        throw ArgumentError('Stripe publishable key is required');
      }
      
      if (!key.startsWith('pk_')) {
        throw ArgumentError('Invalid Stripe publishable key format');
      }
      
      _publishableKey = key;
      
      // Initialize Stripe SDK
      Stripe.publishableKey = key;
      
      _isInitialized = true;
      dev.log('✅ Stripe initialized successfully with key: ${key.substring(0, 12)}...');
      
    } catch (e) {
      dev.log('❌ Error during Stripe initialization: $e');
      if (e is ArgumentError) rethrow;
      throw Exception('Stripe initialization failed: $e');
    }
  }
  
  /// Create a payment intent for the given amount
  Future<PaymentIntentResult> createPaymentIntent({
    required double amount,
    String currency = 'eur',
    Map<String, dynamic>? metadata,
  }) async {
    _ensureInitialized();
    
    try {
      // Validate amount
      if (amount <= 0) {
        throw ArgumentError('Amount must be greater than 0');
      }
      
      if (amount > 999999.99) {
        throw ArgumentError('Amount exceeds maximum limit');
      }
      
      // Convert amount to cents (Stripe requirement)
      final amountInCents = (amount * 100).round();
      
      dev.log('🔄 Creating payment intent for ${amount} ${currency.toUpperCase()}...');
      
      // Simulate payment intent creation for testing
      // In production, this would call your backend API
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      final paymentIntentId = 'pi_test_${DateTime.now().millisecondsSinceEpoch}';
      final clientSecret = '${paymentIntentId}_secret_${DateTime.now().millisecondsSinceEpoch}';
      
      dev.log('✅ Payment intent created: $paymentIntentId');
      
      return PaymentIntentResult(
        id: paymentIntentId,
        clientSecret: clientSecret,
        amount: amountInCents,
        currency: currency,
        status: 'requires_payment_method',
        metadata: metadata,
      );
      
    } catch (e) {
      dev.log('❌ Error creating payment intent: $e');
      if (e is ArgumentError) rethrow;
      throw Exception('Payment setup failed: $e');
    }
  }
  
  /// Confirm a payment with the given client secret and payment method
  Future<BasicPaymentResult> confirmPayment({
    required String clientSecret,
    required String paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    _ensureInitialized();
    
    try {
      // Validate client secret format
      if (!clientSecret.contains('_secret_')) {
        throw ArgumentError('Invalid client secret format');
      }
      
      if (paymentMethodId.isEmpty) {
        throw ArgumentError('Payment method ID is required');
      }
      
      dev.log('🔄 Confirming payment with client secret: ${clientSecret.substring(0, 20)}...');
      
      // Simulate payment confirmation for testing
      await Future.delayed(const Duration(milliseconds: 1000)); // Simulate processing time
      
      // Simulate different payment scenarios based on payment method ID
      if (paymentMethodId.contains('declined')) {
        dev.log('❌ Payment declined (simulated)');
        return BasicPaymentResult.failure(
          error: 'Your card was declined',
          status: PaymentStatus.failed,
          metadata: metadata,
        );
      }
      
      if (paymentMethodId.contains('authentication')) {
        dev.log('🔐 Payment requires authentication (simulated)');
        return BasicPaymentResult.requiresAction(
          clientSecret: clientSecret,
          metadata: metadata,
        );
      }
      
      // Default: successful payment
      dev.log('✅ Payment confirmed successfully (simulated)');
      return BasicPaymentResult(
        isSuccess: true,
        status: PaymentStatus.succeeded,
        paymentIntentId: clientSecret.split('_').first,
        clientSecret: clientSecret,
        metadata: metadata,
      );
      
    } catch (e) {
      dev.log('❌ Error confirming payment: $e');
      if (e is ArgumentError) {
        return BasicPaymentResult.failure(
          error: e.message,
          status: PaymentStatus.failed,
          metadata: metadata,
        );
      }
      return BasicPaymentResult.failure(
        error: 'Payment failed: $e',
        status: PaymentStatus.failed,
        metadata: metadata,
      );
    }
  }
  
  /// Ensure Stripe is initialized before operations
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('StripeService must be initialized before use');
    }
  }
}

/// Result of payment intent creation
class PaymentIntentResult {
  final String id;
  final String clientSecret;
  final int amount;
  final String currency;
  final String status;
  final Map<String, dynamic>? metadata;
  
  const PaymentIntentResult({
    required this.id,
    required this.clientSecret,
    required this.amount,
    required this.currency,
    required this.status,
    this.metadata,
  });
  
  @override
  String toString() {
    return 'PaymentIntentResult(id: $id, amount: $amount, currency: $currency, status: $status)';
  }
}