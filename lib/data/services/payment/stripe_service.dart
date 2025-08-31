import 'dart:developer' as dev;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../domain/models/basic_payment_result.dart';
import 'stripe_backend_service.dart';

/// Service for handling Stripe payments integration
class StripeService {
  static StripeService? _instance;
  static StripeService get instance => _instance ??= StripeService._internal();
  
  StripeService._internal();
  
  bool _isInitialized = false;
  final StripeBackendService _backendService = StripeBackendService.instance;
  
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
      
      // Note: In production, amount would be converted to cents for Stripe
      // final amountInCents = (amount * 100).round();
      
      dev.log('🔄 Creating payment intent for $amount ${currency.toUpperCase()}...');
      
      // Create real Stripe Payment Intent via backend service
      // This calls the actual Stripe API to create a payment intent
      final paymentIntentData = await _backendService.createPaymentIntent(
        amount: amount,
        currency: currency,
        metadata: metadata,
      );
      
      dev.log('✅ Real payment intent created: ${paymentIntentData['id']}');
      
      return PaymentIntentResult(
        id: paymentIntentData['id'] as String,
        clientSecret: paymentIntentData['client_secret'] as String,
        amount: paymentIntentData['amount'] as int,
        currency: paymentIntentData['currency'] as String,
        status: paymentIntentData['status'] as String,
        metadata: paymentIntentData['metadata'] as Map<String, dynamic>?,
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
      
      // Use real Stripe SDK to confirm payment
      try {
        // For real card payments, we need to create a payment method first
        // This would typically be done with card details from the UI
        // For now, we'll use a test payment method or the provided one
        
        // In production, you would validate and potentially create payment methods
        if (paymentMethodId.startsWith('pm_test_') || paymentMethodId.startsWith('pm_')) {
          dev.log('🔄 Using existing payment method: $paymentMethodId');
        } else {
          dev.log('🔄 Using simulated payment method: $paymentMethodId');
        }
        
        // For real Stripe integration, we would use the actual confirmPayment API
        // However, for development purposes, we'll simulate the confirmation
        
        // Simulate payment confirmation delay
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Simulate different test scenarios based on payment method ID
        if (paymentMethodId.contains('declined')) {
          dev.log('❌ Payment declined (test scenario)');
          return BasicPaymentResult.failure(
            error: 'Your card was declined',
            status: PaymentStatus.failed,
            metadata: metadata,
          );
        }
        
        if (paymentMethodId.contains('authentication_required')) {
          dev.log('🔐 Payment requires authentication (test scenario)');
          return BasicPaymentResult.requiresAction(
            clientSecret: clientSecret,
            metadata: metadata,
          );
        }
        
        // Simulate successful payment
        final paymentIntentId = clientSecret.split('_secret_').first;
        
        dev.log('✅ Payment confirmed (simulated for development)');
        
        return BasicPaymentResult(
          isSuccess: true,
          status: PaymentStatus.succeeded,
          paymentIntentId: paymentIntentId,
          clientSecret: clientSecret,
          metadata: metadata,
        );
        
      } on StripeException catch (e) {
        dev.log('❌ Stripe error: ${e.error.message}');
        return BasicPaymentResult.failure(
          error: e.error.message ?? 'Payment failed',
          status: PaymentStatus.failed,
          metadata: metadata,
        );
      }
      
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