import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for communicating with Stripe backend
/// In production, this would call your actual backend server
/// For development, this simulates backend-to-Stripe communication
class StripeBackendService {
  static StripeBackendService? _instance;
  static StripeBackendService get instance => _instance ??= StripeBackendService._internal();
  
  StripeBackendService._internal();
  
  static const String _stripeApiBase = 'https://api.stripe.com/v1';
  
  /// Create a payment intent on Stripe's servers
  /// In production, this call would go to your backend, which would then call Stripe
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    String currency = 'eur',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final secretKey = dotenv.env['STRIPE_SECRET_KEY_TEST'];
      
      if (secretKey == null || !secretKey.startsWith('sk_test_')) {
        throw ArgumentError('Valid Stripe secret key is required for backend operations');
      }
      
      // Convert amount to cents
      final amountInCents = (amount * 100).round();
      
      // Prepare request body
      final body = {
        'amount': amountInCents.toString(),
        'currency': currency,
        'confirm': 'false', // Don't auto-confirm, let client handle confirmation
        'payment_method_types[]': 'card',
        if (metadata != null) ...metadata.map((key, value) => MapEntry('metadata[$key]', value.toString())),
      };
      
      dev.log('🔄 Creating real Stripe payment intent for €${amount.toStringAsFixed(2)}...');
      
      // Call Stripe API directly (in production, this would be your backend)
      final response = await http.post(
        Uri.parse('$_stripeApiBase/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        dev.log('✅ Payment intent created: ${data['id']}');
        return data;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        final error = errorData['error'] as Map<String, dynamic>? ?? {};
        throw StripeBackendException(
          error['message'] as String? ?? 'Unknown error',
          error['code'] as String?,
        );
      }
      
    } catch (e) {
      dev.log('❌ Error creating payment intent: $e');
      if (e is StripeBackendException) rethrow;
      throw StripeBackendException('Failed to create payment intent: $e');
    }
  }
  
  /// Retrieve a payment intent from Stripe
  Future<Map<String, dynamic>> retrievePaymentIntent(String paymentIntentId) async {
    try {
      final secretKey = dotenv.env['STRIPE_SECRET_KEY_TEST'];
      
      if (secretKey == null || !secretKey.startsWith('sk_test_')) {
        throw ArgumentError('Valid Stripe secret key is required for backend operations');
      }
      
      dev.log('🔄 Retrieving payment intent: $paymentIntentId');
      
      final response = await http.get(
        Uri.parse('$_stripeApiBase/payment_intents/$paymentIntentId'),
        headers: {
          'Authorization': 'Bearer $secretKey',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        dev.log('✅ Payment intent retrieved: ${data['status']}');
        return data;
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        final error = errorData['error'] as Map<String, dynamic>? ?? {};
        throw StripeBackendException(
          error['message'] as String? ?? 'Unknown error',
          error['code'] as String?,
        );
      }
      
    } catch (e) {
      dev.log('❌ Error retrieving payment intent: $e');
      if (e is StripeBackendException) rethrow;
      throw StripeBackendException('Failed to retrieve payment intent: $e');
    }
  }
}

/// Exception thrown by Stripe backend operations
class StripeBackendException implements Exception {
  final String message;
  final String? code;
  
  const StripeBackendException(this.message, [this.code]);
  
  @override
  String toString() => 'StripeBackendException: $message${code != null ? ' (code: $code)' : ''}';
}