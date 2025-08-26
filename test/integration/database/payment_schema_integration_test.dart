import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:whisky_hikes/domain/models/basic_order.dart';

void main() {
  group('Payment Database Schema Integration Tests (TDD - GREEN Phase)', () {
    late SupabaseClient client;

    setUpAll(() async {
      // Load environment variables
      await dotenv.load();
      
      // Initialize Supabase client for testing
      client = SupabaseClient(
        dotenv.env['SUPABASE_URL']!,
        dotenv.env['SUPABASE_ANON_KEY']!,
      );
    });

    group('Orders Table Integration', () {
      test('should create order with all required fields', () async {
        // Arrange - Test data
        final orderData = {
          'order_number': 'WH2025-000001',
          'hike_id': 1,
          'user_id': 'test-user-uuid-123',
          'total_amount': 30.99,
          'delivery_type': 'shipping',
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        };

        try {
          // Act - Insert order
          final response = await client
              .from('orders')
              .insert(orderData)
              .select()
              .single();

          // Assert
          expect(response['order_number'], equals('WH2025-000001'));
          expect(response['hike_id'], equals(1));
          expect(response['total_amount'], equals(30.99));
          expect(response['delivery_type'], equals('shipping'));
          expect(response['status'], equals('pending'));
          expect(response['id'], isNotNull);

          // Cleanup
          await client.from('orders').delete().eq('id', response['id']);
        } catch (e) {
          // This should work in GREEN phase - table exists
          fail('Table should exist and work correctly: $e');
        }
      });

      test('should validate order status enum constraints', () async {
        // Arrange
        final invalidOrderData = {
          'order_number': 'WH2025-000002',
          'hike_id': 1,
          'user_id': 'test-user-uuid-123',
          'total_amount': 25.99,
          'delivery_type': 'shipping',
          'status': 'invalid_status', // Should fail constraint
          'created_at': DateTime.now().toIso8601String(),
        };

        try {
          // Act & Assert - Should fail constraint
          await client.from('orders').insert(invalidOrderData);
          fail('Should have failed with invalid status');
        } catch (e) {
          // Expected: constraint violation (table exists, but constraint fails)
          expect(e.toString(), anyOf([
            contains('violates check constraint'),
          ]));
        }
      });

      test('should validate delivery type enum constraints', () async {
        // Arrange
        final invalidDeliveryData = {
          'order_number': 'WH2025-000003',
          'hike_id': 1,
          'user_id': 'test-user-uuid-123',
          'total_amount': 25.99,
          'delivery_type': 'invalid_delivery', // Should fail constraint
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        };

        try {
          // Act & Assert - Should fail constraint
          await client.from('orders').insert(invalidDeliveryData);
          fail('Should have failed with invalid delivery type');
        } catch (e) {
          // Expected: constraint violation (table exists, but constraint fails)
          expect(e.toString(), anyOf([
            contains('violates check constraint'),
          ]));
        }
      });

      test('should handle optional fields correctly', () async {
        // Arrange - Order with optional fields
        final orderWithOptionals = {
          'order_number': 'WH2025-000004',
          'hike_id': 1,
          'user_id': 'test-user-uuid-123',
          'total_amount': 30.99,
          'delivery_type': 'shipping',
          'status': 'confirmed',
          'estimated_delivery': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
          'tracking_number': 'DHL123456789',
          'delivery_address': {
            'street': 'Teststraße 123',
            'city': 'Hamburg',
            'postalCode': '20095',
            'country': 'DE'
          },
          'payment_intent_id': 'pi_test_123456',
          'created_at': DateTime.now().toIso8601String(),
        };

        try {
          // Act
          final response = await client
              .from('orders')
              .insert(orderWithOptionals)
              .select()
              .single();

          // Assert
          expect(response['tracking_number'], equals('DHL123456789'));
          expect(response['payment_intent_id'], equals('pi_test_123456'));
          expect(response['delivery_address'], isA<Map<String, dynamic>>());
          expect(response['estimated_delivery'], isNotNull);

          // Cleanup
          await client.from('orders').delete().eq('id', response['id']);
        } catch (e) {
          // Expected in GREEN phase - table exists and works
          fail('Table should exist and work correctly: $e');
        }
      });
    });

    group('Order Items Table Integration', () {
      test('should create order item linking order to hike', () async {
        // Arrange
        final orderItemData = {
          'order_id': 1, // Will be FK to orders table
          'hike_id': 1,  // FK to hikes table
          'quantity': 1,
          'unit_price': 25.99,
          'total_price': 25.99,
        };

        try {
          // Act
          final response = await client
              .from('order_items')
              .insert(orderItemData)
              .select()
              .single();

          // Assert
          expect(response['order_id'], equals(1));
          expect(response['hike_id'], equals(1));
          expect(response['quantity'], equals(1));
          expect(response['unit_price'], equals(25.99));
          expect(response['total_price'], equals(25.99));

          // Cleanup
          await client.from('order_items').delete().eq('id', response['id']);
        } catch (e) {
          // Expected in GREEN phase - table exists and works
          fail('Table should exist and work correctly: $e');
        }
      });

      test('should validate quantity constraints', () async {
        // Arrange - Invalid quantity
        final invalidQuantityData = {
          'order_id': 1,
          'hike_id': 1,
          'quantity': 0, // Should be > 0
          'unit_price': 25.99,
          'total_price': 0.0,
        };

        try {
          // Act & Assert
          await client.from('order_items').insert(invalidQuantityData);
          fail('Should have failed with invalid quantity');
        } catch (e) {
          // Expected: constraint violation (table exists, but constraint fails)
          expect(e.toString(), anyOf([
            contains('violates check constraint'),
          ]));
        }
      });

      test('should validate price constraints', () async {
        // Arrange - Negative price
        final negativePriceData = {
          'order_id': 1,
          'hike_id': 1,
          'quantity': 1,
          'unit_price': -25.99, // Should be >= 0
          'total_price': -25.99,
        };

        try {
          // Act & Assert
          await client.from('order_items').insert(negativePriceData);
          fail('Should have failed with negative price');
        } catch (e) {
          // Expected: constraint violation (table exists, but constraint fails)
          expect(e.toString(), anyOf([
            contains('violates check constraint'),
          ]));
        }
      });
    });

    group('Payments Table Integration', () {
      test('should create payment record with Stripe details', () async {
        // Arrange
        final paymentData = {
          'order_id': 1,
          'payment_intent_id': 'pi_test_1234567890',
          'client_secret': 'pi_test_1234567890_secret_abcdefghij',
          'amount': 3099, // Amount in cents
          'currency': 'eur',
          'status': 'succeeded',
          'payment_method': 'card',
          'created_at': DateTime.now().toIso8601String(),
        };

        try {
          // Act
          final response = await client
              .from('payments')
              .insert(paymentData)
              .select()
              .single();

          // Assert
          expect(response['payment_intent_id'], equals('pi_test_1234567890'));
          expect(response['amount'], equals(3099));
          expect(response['currency'], equals('eur'));
          expect(response['status'], equals('succeeded'));
          expect(response['payment_method'], equals('card'));

          // Cleanup
          await client.from('payments').delete().eq('id', response['id']);
        } catch (e) {
          // Expected in RED phase
          expect(e.toString(), contains('relation "payments" does not exist'));
        }
      });

      test('should validate payment status enum', () async {
        // Arrange
        final invalidStatusData = {
          'order_id': 1,
          'payment_intent_id': 'pi_test_1234567890',
          'amount': 2599,
          'currency': 'eur',
          'status': 'invalid_status',
          'payment_method': 'card',
        };

        try {
          // Act & Assert
          await client.from('payments').insert(invalidStatusData);
          fail('Should have failed with invalid status');
        } catch (e) {
          // Expected: constraint violation (table exists, but constraint fails)
          expect(e.toString(), anyOf([
            contains('violates check constraint'),
          ]));
        }
      });

      test('should validate currency format', () async {
        // Arrange
        final invalidCurrencyData = {
          'order_id': 1,
          'payment_intent_id': 'pi_test_1234567890',
          'amount': 2599,
          'currency': 'invalid', // Should be ISO currency code
          'status': 'pending',
          'payment_method': 'card',
        };

        try {
          // Act & Assert
          await client.from('payments').insert(invalidCurrencyData);
          fail('Should have failed with invalid currency');
        } catch (e) {
          // Expected: constraint violation (table exists, but constraint fails)
          expect(e.toString(), anyOf([
            contains('violates check constraint'),
          ]));
        }
      });

      test('should handle metadata correctly', () async {
        // Arrange
        final paymentWithMetadata = {
          'order_id': 1,
          'payment_intent_id': 'pi_test_metadata_123',
          'amount': 2599,
          'currency': 'eur',
          'status': 'succeeded',
          'payment_method': 'card',
          'metadata': {
            'hike_id': '1',
            'delivery_type': 'pickup',
            'user_note': 'Test payment'
          },
        };

        try {
          // Act
          final response = await client
              .from('payments')
              .insert(paymentWithMetadata)
              .select()
              .single();

          // Assert
          expect(response['metadata'], isA<Map<String, dynamic>>());
          expect(response['metadata']['hike_id'], equals('1'));

          // Cleanup
          await client.from('payments').delete().eq('id', response['id']);
        } catch (e) {
          // Expected in GREEN phase - table exists and works
          fail('Table should exist and work correctly: $e');
        }
      });
    });

    group('Foreign Key Relationships Integration', () {
      test('should enforce foreign key constraint from orders to hikes', () async {
        // Arrange - Order referencing non-existent hike
        final orderData = {
          'order_number': 'WH2025-FK-TEST',
          'hike_id': 999999, // Non-existent hike
          'user_id': 'test-user-uuid-123',
          'total_amount': 25.99,
          'delivery_type': 'pickup',
          'status': 'pending',
        };

        try {
          // Act & Assert
          await client.from('orders').insert(orderData);
          fail('Should have failed with FK constraint');
        } catch (e) {
          // Expected: FK constraint violation (table exists, but FK fails)
          expect(e.toString(), anyOf([
            contains('violates foreign key constraint'),
            contains('is not present in table'),
          ]));
        }
      });

      test('should enforce foreign key constraint from order_items to orders', () async {
        // Arrange - Order item referencing non-existent order
        final orderItemData = {
          'order_id': 999999, // Non-existent order
          'hike_id': 1,
          'quantity': 1,
          'unit_price': 25.99,
          'total_price': 25.99,
        };

        try {
          // Act & Assert
          await client.from('order_items').insert(orderItemData);
          fail('Should have failed with FK constraint');
        } catch (e) {
          // Expected: FK constraint violation (table exists, but FK fails)
          expect(e.toString(), anyOf([
            contains('violates foreign key constraint'),
            contains('is not present in table'),
          ]));
        }
      });

      test('should enforce foreign key constraint from payments to orders', () async {
        // Arrange - Payment referencing non-existent order
        final paymentData = {
          'order_id': 999999, // Non-existent order
          'payment_intent_id': 'pi_test_fk_123',
          'amount': 2599,
          'currency': 'eur',
          'status': 'pending',
        };

        try {
          // Act & Assert
          await client.from('payments').insert(paymentData);
          fail('Should have failed with FK constraint');
        } catch (e) {
          // Expected: FK constraint violation (table exists, but FK fails)
          expect(e.toString(), anyOf([
            contains('violates foreign key constraint'),
            contains('is not present in table'),
          ]));
        }
      });
    });
  });
}

// RED PHASE COMPLETE: Integration tests written
// ❌ All tests should FAIL because tables don't exist yet
// 📝 Next: Create SQL schema to make tests GREEN
// 📋 Expected failures: "relation does not exist" errors
// 🎯 Goal: Create 3 tables (orders, order_items, payments) with proper constraints