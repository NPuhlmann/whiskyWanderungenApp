import 'dart:developer' as dev;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pay/pay.dart';

import '../../../domain/models/payment_intent.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentMethodType;

/// Enhanced payment service supporting multiple payment methods
/// Includes Apple Pay, Google Pay, PayPal, and Card payments
class MultiPaymentService {
  static MultiPaymentService? _instance;
  static MultiPaymentService get instance =>
      _instance ??= MultiPaymentService._internal();

  MultiPaymentService._internal();

  bool _isInitialized = false;

  // Apple Pay & Google Pay configurations
  PaymentConfiguration? _applePayConfig;
  PaymentConfiguration? _googlePayConfig;

  /// Initialize all payment services
  Future<void> initialize() async {
    try {
      dev.log('🔄 Initializing MultiPaymentService...');

      // Publishable key only — intents are created by the Edge Function
      _initializeStripe();

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

  /// Hand the Stripe SDK its publishable key so it can confirm intents.
  ///
  /// Only the publishable key ever reaches the client (ADR-0006) — payment
  /// intents are created server-side by the `create-payment-intent` Edge
  /// Function.
  void _initializeStripe() {
    final key = dotenv.env['STRIPE_PUBLISHABLE_KEY_TEST'];

    if (key == null || key.isEmpty || !key.startsWith('pk_')) {
      throw ArgumentError(
        'A valid Stripe publishable key (pk_...) is required',
      );
    }

    Stripe.publishableKey = key;
    dev.log('✅ Stripe publishable key configured');
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
        dev.log(
          '⚠️ Google Pay merchant ID not configured - skipping Google Pay',
        );
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
          dev.log(
            '📱 Checking Apple Pay availability (simulated for development)',
          );
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
          dev.log(
            '🤖 Checking Google Pay availability (simulated for development)',
          );
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

    dev.log(
      '✅ Available payment methods: ${availableMethods.map((m) => m.name).join(', ')}',
    );
    return availableMethods;
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
