import 'dart:developer' as dev;
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay/pay.dart';

import '../../../domain/models/basic_payment_result.dart';
import '../../../domain/models/payment_intent.dart';
import 'stripe_service.dart';

/// Enhanced payment service supporting multiple payment methods
/// Includes Apple Pay, Google Pay, PayPal, and Card payments
class MultiPaymentService {
  static MultiPaymentService? _instance;
  static MultiPaymentService get instance => _instance ??= MultiPaymentService._internal();
  
  MultiPaymentService._internal();
  
  bool _isInitialized = false;
  final StripeService _stripeService = StripeService.instance;
  
  // Apple Pay & Google Pay configurations
  PaymentConfiguration? _applePayConfig;
  PaymentConfiguration? _googlePayConfig;

  /// Initialize all payment services
  Future<void> initialize() async {
    try {
      dev.log('🔄 Initializing MultiPaymentService...');
      
      // Initialize Stripe (existing)
      await _stripeService.initialize();
      
      // Initialize Apple Pay configuration
      await _initializeApplePay();
      
      // Initialize Google Pay configuration  
      await _initializeGooglePay();
      
      // PayPal initialization will be handled per-payment
      
      _isInitialized = true;
      dev.log('✅ MultiPaymentService initialized successfully');
      
    } catch (e) {
      dev.log('❌ Error initializing MultiPaymentService: $e');
      throw Exception('MultiPaymentService initialization failed: $e');
    }
  }

  /// Initialize Apple Pay configuration
  Future<void> _initializeApplePay() async {
    try {
      final merchantId = dotenv.env['APPLE_PAY_MERCHANT_ID_TEST'];
      final displayName = dotenv.env['APPLE_MERCHANT_DISPLAY_NAME_TEST'];
      
      if (merchantId == null || merchantId.isEmpty) {
        dev.log('⚠️ Apple Pay merchant ID not configured - skipping Apple Pay');
        return;
      }
      
      _applePayConfig = PaymentConfiguration.fromJsonString('''
        {
          "provider": "apple_pay",
          "data": {
            "merchantIdentifier": "$merchantId",
            "displayName": "$displayName",
            "merchantCapabilities": ["3DS", "debit", "credit"],
            "supportedNetworks": ["amex", "discover", "masterCard", "visa"],
            "countryCode": "DE",
            "currencyCode": "EUR"
          }
        }
      ''');
      
      dev.log('✅ Apple Pay configuration loaded');
    } catch (e) {
      dev.log('⚠️ Apple Pay configuration failed: $e');
      // Continue without Apple Pay
    }
  }

  /// Initialize Google Pay configuration
  Future<void> _initializeGooglePay() async {
    try {
      final merchantId = dotenv.env['GOOGLE_PAY_MERCHANT_ID_TEST'];
      final merchantName = dotenv.env['GOOGLE_PAY_MERCHANT_NAME_TEST'];
      
      if (merchantId == null || merchantId.isEmpty) {
        dev.log('⚠️ Google Pay merchant ID not configured - skipping Google Pay');
        return;
      }
      
      _googlePayConfig = PaymentConfiguration.fromJsonString('''
        {
          "provider": "google_pay",
          "data": {
            "environment": "TEST",
            "apiVersion": 2,
            "apiVersionMinor": 0,
            "allowedPaymentMethods": [
              {
                "type": "CARD",
                "parameters": {
                  "allowedCardNetworks": ["AMEX", "DISCOVER", "MASTERCARD", "VISA"],
                  "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"]
                },
                "tokenizationSpecification": {
                  "type": "PAYMENT_GATEWAY",
                  "parameters": {
                    "gateway": "stripe",
                    "gatewayMerchantId": "$merchantId"
                  }
                }
              }
            ],
            "merchantInfo": {
              "merchantId": "$merchantId",
              "merchantName": "$merchantName"
            },
            "transactionInfo": {
              "countryCode": "DE",
              "currencyCode": "EUR"
            }
          }
        }
      ''');
      
      dev.log('✅ Google Pay configuration loaded');
    } catch (e) {
      dev.log('⚠️ Google Pay configuration failed: $e');
      // Continue without Google Pay
    }
  }

  /// Check if a payment method is available on this device
  Future<bool> isPaymentMethodAvailable(PaymentMethodType paymentMethod) async {
    _ensureInitialized();
    
    switch (paymentMethod) {
      case PaymentMethodType.card:
        return true; // Always available via Stripe
        
      case PaymentMethodType.applePay:
        if (_applePayConfig == null) return false;
        try {
          // For now, simulate Apple Pay availability check
          // In production, you would use platform-specific availability checks
          dev.log('📱 Checking Apple Pay availability (simulated for development)');
          await Future.delayed(const Duration(milliseconds: 100));
          return _applePayConfig != null; // Available if config exists
        } catch (e) {
          dev.log('❌ Apple Pay not available: $e');
          return false;
        }
        
      case PaymentMethodType.googlePay:
        if (_googlePayConfig == null) return false;
        try {
          // For now, simulate Google Pay availability check
          // In production, you would use platform-specific availability checks
          dev.log('🤖 Checking Google Pay availability (simulated for development)');
          await Future.delayed(const Duration(milliseconds: 100));
          return _googlePayConfig != null; // Available if config exists
        } catch (e) {
          dev.log('❌ Google Pay not available: $e');
          return false;
        }
        
      default:
        return false; // Other methods not yet implemented
    }
  }

  /// Get list of available payment methods for this device
  Future<List<PaymentMethodType>> getAvailablePaymentMethods() async {
    final List<PaymentMethodType> availableMethods = [];
    
    // Check each payment method
    for (final method in PaymentMethodType.values) {
      if (await isPaymentMethodAvailable(method)) {
        availableMethods.add(method);
      }
    }
    
    dev.log('✅ Available payment methods: ${availableMethods.map((m) => m.name).join(', ')}');
    return availableMethods;
  }

  /// Process payment with the specified method
  Future<BasicPaymentResult> processPayment({
    required PaymentMethodType paymentMethod,
    required double amount,
    String currency = 'eur',
    Map<String, dynamic>? metadata,
  }) async {
    _ensureInitialized();
    
    dev.log('🔄 Processing payment: ${paymentMethod.name}, amount: $amount $currency');
    
    try {
      switch (paymentMethod) {
        case PaymentMethodType.card:
          return await _processCardPayment(amount: amount, currency: currency, metadata: metadata);
          
        case PaymentMethodType.applePay:
          return await _processApplePayPayment(amount: amount, currency: currency, metadata: metadata);
          
        case PaymentMethodType.googlePay:
          return await _processGooglePayPayment(amount: amount, currency: currency, metadata: metadata);
          
        default:
          throw ArgumentError('Payment method ${paymentMethod.name} not implemented');
      }
    } catch (e) {
      dev.log('❌ Payment processing failed: $e');
      return BasicPaymentResult.failure(
        error: 'Payment failed: ${e.toString()}',
        status: PaymentStatus.failed,
        metadata: metadata,
      );
    }
  }

  /// Process card payment via Stripe
  Future<BasicPaymentResult> _processCardPayment({
    required double amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Create payment intent
      final paymentIntent = await _stripeService.createPaymentIntent(
        amount: amount,
        currency: currency,
        metadata: metadata,
      );
      
      // Simulate payment method ID for testing
      final paymentMethodId = 'pm_card_visa_test_${DateTime.now().millisecondsSinceEpoch}';
      
      // Confirm payment
      return await _stripeService.confirmPayment(
        clientSecret: paymentIntent.clientSecret,
        paymentMethodId: paymentMethodId,
        metadata: metadata,
      );
    } catch (e) {
      throw Exception('Card payment failed: $e');
    }
  }

  /// Process Apple Pay payment
  Future<BasicPaymentResult> _processApplePayPayment({
    required double amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    if (_applePayConfig == null) {
      throw Exception('Apple Pay not configured');
    }
    
    try {
      dev.log('🍎 Processing Apple Pay payment (simulated for development)...');
      
      // Simulate Apple Pay processing delay
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // For development, simulate successful Apple Pay payment
      dev.log('✅ Apple Pay payment successful (simulated)');
      return BasicPaymentResult(
        isSuccess: true,
        status: PaymentStatus.succeeded,
        paymentIntentId: 'pi_apple_pay_${DateTime.now().millisecondsSinceEpoch}',
        metadata: {...?metadata, 'payment_method': 'apple_pay'},
      );
      
    } catch (e) {
      dev.log('❌ Apple Pay payment failed: $e');
      if (e is PlatformException && e.code == 'UserCancel') {
        return BasicPaymentResult.cancelled(
          message: 'Apple Pay was cancelled by user',
        );
      }
      throw Exception('Apple Pay payment failed: $e');
    }
  }

  /// Process Google Pay payment
  Future<BasicPaymentResult> _processGooglePayPayment({
    required double amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    if (_googlePayConfig == null) {
      throw Exception('Google Pay not configured');
    }
    
    try {
      dev.log('🤖 Processing Google Pay payment (simulated for development)...');
      
      // Simulate Google Pay processing delay
      await Future.delayed(const Duration(milliseconds: 1200));
      
      // For development, simulate successful Google Pay payment
      dev.log('✅ Google Pay payment successful (simulated)');
      return BasicPaymentResult(
        isSuccess: true,
        status: PaymentStatus.succeeded,
        paymentIntentId: 'pi_google_pay_${DateTime.now().millisecondsSinceEpoch}',
        metadata: {...?metadata, 'payment_method': 'google_pay'},
      );
      
    } catch (e) {
      dev.log('❌ Google Pay payment failed: $e');
      if (e is PlatformException && e.code == 'UserCancel') {
        return BasicPaymentResult.cancelled(
          message: 'Google Pay was cancelled by user',
        );
      }
      throw Exception('Google Pay payment failed: $e');
    }
  }


  /// Get display name for payment method
  String getPaymentMethodDisplayName(PaymentMethodType paymentMethod) {
    switch (paymentMethod) {
      case PaymentMethodType.card:
        return 'Kreditkarte';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
      case PaymentMethodType.sepaDebit:
        return 'SEPA Lastschrift';
      case PaymentMethodType.sofort:
        return 'Sofort';
      case PaymentMethodType.giropay:
        return 'Giropay';
      case PaymentMethodType.ideal:
        return 'iDEAL';
    }
  }

  /// Get icon name for payment method
  String getPaymentMethodIcon(PaymentMethodType paymentMethod) {
    switch (paymentMethod) {
      case PaymentMethodType.card:
        return 'credit_card';
      case PaymentMethodType.applePay:
        return 'apple';
      case PaymentMethodType.googlePay:
        return 'google';
      case PaymentMethodType.sepaDebit:
        return 'account_balance';
      case PaymentMethodType.sofort:
        return 'flash_on';
      case PaymentMethodType.giropay:
        return 'euro_symbol';
      case PaymentMethodType.ideal:
        return 'euro_symbol';
    }
  }

  /// Note: Pay integration will be implemented in future versions
  /// For now, Apple Pay and Google Pay use simulated flows

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('MultiPaymentService must be initialized before use');
    }
  }
}

/// Payment processing completed using simulated flows for development
/// Real Pay integration will be implemented in Phase 3