import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:whisky_hikes/data/services/database/backend_api.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';

// Simplified mock - focusing on the final result rather than chain mocking
class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('BackendApiService Payment Extension Tests (TDD - Green Phase)', () {
    late BackendApiService apiService;
    late MockSupabaseClient mockClient;

    setUp(() {
      mockClient = MockSupabaseClient();
      apiService = BackendApiService(client: mockClient);
      
      // Setup basic mock for the complex chain
      when(mockClient.from(any)).thenReturn(_FakeQueryBuilder());
    });

    group('Order Management', () {
      test('should fetch user orders with proper query', () async {
        // Arrange
        final String userId = 'test-user-123';
        final List<Map<String, dynamic>> mockOrderData = [
          {
            'id': 1,
            'order_number': 'WH2025-001',
            'hike_id': 5,
            'user_id': userId,
            'total_amount': 25.99,
            'delivery_type': 'pickup',
            'status': 'confirmed',
            'created_at': DateTime.now().toIso8601String(),
          },
          {
            'id': 2,
            'order_number': 'WH2025-002',
            'hike_id': 7,
            'user_id': userId,
            'total_amount': 30.99,
            'delivery_type': 'shipping',
            'status': 'pending',
            'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          },
        ];

        // Mock the chain: from -> eq -> order -> response
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', userId)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('created_at', ascending: false))
            .thenAnswer((_) async => mockOrderData);

        // Act
        final result = await apiService.fetchUserOrders(userId);

        // Assert
        expect(result, hasLength(2));
        expect(result[0], isA<BasicOrder>());
        expect(result[0].orderNumber, equals('WH2025-001'));
        expect(result[0].status, equals(OrderStatus.confirmed));
        expect(result[1].orderNumber, equals('WH2025-002'));
        expect(result[1].status, equals(OrderStatus.pending));

        // Verify proper query chain
        verify(mockClient.from('orders')).called(1);
        verify(mockQueryBuilder.select()).called(1);
        verify(mockFilterBuilder.eq('user_id', userId)).called(1);
        verify(mockTransformBuilder.order('created_at', ascending: false)).called(1);
      });

      test('should handle empty order list gracefully', () async {
        // Arrange
        final String userId = 'user-with-no-orders';
        
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', userId)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('created_at', ascending: false))
            .thenAnswer((_) async => <Map<String, dynamic>>[]);

        // Act
        final result = await apiService.fetchUserOrders(userId);

        // Assert
        expect(result, isEmpty);
        expect(result, isA<List<BasicOrder>>());
      });

      test('should fetch order by ID', () async {
        // Arrange
        final int orderId = 123;
        final Map<String, dynamic> mockOrderData = {
          'id': orderId,
          'order_number': 'WH2025-123',
          'hike_id': 8,
          'user_id': 'test-user-456',
          'total_amount': 45.99,
          'delivery_type': 'shipping',
          'status': 'shipped',
          'tracking_number': 'DHL12345',
          'created_at': DateTime.now().toIso8601String(),
        };

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', orderId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => mockOrderData);

        // Act
        final result = await apiService.fetchOrderById(orderId);

        // Assert
        expect(result, isA<BasicOrder>());
        expect(result.id, equals(orderId));
        expect(result.orderNumber, equals('WH2025-123'));
        expect(result.status, equals(OrderStatus.shipped));
        expect(result.trackingNumber, equals('DHL12345'));

        verify(mockClient.from('orders')).called(1);
        verify(mockFilterBuilder.eq('id', orderId)).called(1);
        verify(mockFilterBuilder.single()).called(1);
      });

      test('should handle order not found error', () async {
        // Arrange
        final int nonExistentOrderId = 999999;
        
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', nonExistentOrderId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenThrow(
          PostgrestException(message: 'No rows returned', details: null, hint: null, code: null)
        );

        // Act & Assert
        expect(() async => await apiService.fetchOrderById(nonExistentOrderId), 
               throwsA(isA<Exception>()));
      });
    });

    group('Hike Purchase Tracking', () {
      test('should check if user has purchased a hike', () async {
        // Arrange
        final String userId = 'test-user-789';
        final int hikeId = 15;
        
        final List<Map<String, dynamic>> mockPurchaseData = [
          {
            'id': 1,
            'user_id': userId,
            'hike_id': hikeId,
            'purchased_at': DateTime.now().toIso8601String(),
          }
        ];

        when(mockClient.from('purchased_hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('id')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', userId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('hike_id', hikeId)).thenAnswer((_) async => mockPurchaseData);

        // Act
        final result = await apiService.hasUserPurchasedHike(userId, hikeId);

        // Assert
        expect(result, isTrue);
        
        verify(mockClient.from('purchased_hikes')).called(1);
        verify(mockQueryBuilder.select('id')).called(1);
        verify(mockFilterBuilder.eq('user_id', userId)).called(1);
        verify(mockFilterBuilder.eq('hike_id', hikeId)).called(1);
      });

      test('should return false when user has not purchased hike', () async {
        // Arrange
        final String userId = 'test-user-999';
        final int hikeId = 25;
        
        when(mockClient.from('purchased_hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('id')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', userId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('hike_id', hikeId)).thenAnswer((_) async => <Map<String, dynamic>>[]);

        // Act
        final result = await apiService.hasUserPurchasedHike(userId, hikeId);

        // Assert
        expect(result, isFalse);
      });

      test('should record hike purchase', () async {
        // Arrange
        final String userId = 'buyer-123';
        final int hikeId = 42;
        final int orderId = 567;
        
        final Map<String, dynamic> expectedData = {
          'user_id': userId,
          'hike_id': hikeId,
          'order_id': orderId,
          'purchased_at': any, // We'll check this is a valid timestamp
        };

        when(mockClient.from('purchased_hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenAnswer((_) async => null);

        // Act
        await apiService.recordHikePurchase(userId, hikeId, orderId);

        // Assert
        verify(mockClient.from('purchased_hikes')).called(1);
        verify(mockQueryBuilder.insert(argThat(predicate<Map<String, dynamic>>((data) {
          return data['user_id'] == userId &&
                 data['hike_id'] == hikeId &&
                 data['order_id'] == orderId &&
                 data.containsKey('purchased_at');
        })))).called(1);
      });

      test('should handle purchase record creation failure', () async {
        // Arrange
        final String userId = 'user-fail';
        final int hikeId = 1;
        final int orderId = 1;
        
        when(mockClient.from('purchased_hikes')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenThrow(
          PostgrestException(message: 'Insert failed', details: null, hint: null, code: null)
        );

        // Act & Assert
        expect(() async => await apiService.recordHikePurchase(userId, hikeId, orderId),
               throwsA(isA<Exception>()));
      });
    });

    group('Payment Integration Support', () {
      test('should get order with payment details', () async {
        // Arrange
        final int orderId = 456;
        final Map<String, dynamic> mockOrderWithPayment = {
          'id': orderId,
          'order_number': 'WH2025-456',
          'hike_id': 12,
          'user_id': 'customer-789',
          'total_amount': 32.50,
          'delivery_type': 'pickup',
          'status': 'confirmed',
          'payment_intent_id': 'pi_test_1234567890',
          'created_at': DateTime.now().toIso8601String(),
        };

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', orderId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => mockOrderWithPayment);

        // Act
        final result = await apiService.fetchOrderWithPaymentDetails(orderId);

        // Assert
        expect(result, isA<BasicOrder>());
        expect(result.paymentIntentId, equals('pi_test_1234567890'));
        expect(result.status, equals(OrderStatus.confirmed));
      });

      test('should update order status after payment', () async {
        // Arrange
        final int orderId = 789;
        final OrderStatus newStatus = OrderStatus.confirmed;
        final String paymentIntentId = 'pi_successful_payment_123';
        
        final Map<String, dynamic> updatedOrderData = {
          'id': orderId,
          'order_number': 'WH2025-789',
          'status': 'confirmed',
          'payment_intent_id': paymentIntentId,
          'updated_at': DateTime.now().toIso8601String(),
        };

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', orderId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => updatedOrderData);

        // Act
        final result = await apiService.updateOrderAfterPayment(
          orderId: orderId,
          status: newStatus,
          paymentIntentId: paymentIntentId,
        );

        // Assert
        expect(result, isA<BasicOrder>());
        expect(result.status, equals(OrderStatus.confirmed));
        expect(result.paymentIntentId, equals(paymentIntentId));

        verify(mockQueryBuilder.update(argThat(predicate<Map<String, dynamic>>((data) {
          return data['status'] == 'confirmed' &&
                 data['payment_intent_id'] == paymentIntentId &&
                 data.containsKey('updated_at');
        })))).called(1);
      });

      test('should get payment history for user', () async {
        // Arrange
        final String userId = 'payment-user-123';
        final List<Map<String, dynamic>> mockPaymentData = [
          {
            'id': 1,
            'order_id': 100,
            'payment_intent_id': 'pi_test_001',
            'amount': 2599, // In cents
            'currency': 'eur',
            'status': 'succeeded',
            'payment_method': 'card',
            'created_at': DateTime.now().toIso8601String(),
          },
          {
            'id': 2,
            'order_id': 101,
            'payment_intent_id': 'pi_test_002',
            'amount': 3099,
            'currency': 'eur',
            'status': 'succeeded',
            'payment_method': 'card',
            'created_at': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          },
        ];

        // Mock complex JOIN query
        when(mockClient.from('payments')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('*, orders!inner(user_id)')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('orders.user_id', userId)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('created_at', ascending: false))
            .thenAnswer((_) async => mockPaymentData);

        // Act
        final result = await apiService.getUserPaymentHistory(userId);

        // Assert
        expect(result, hasLength(2));
        expect(result[0]['payment_intent_id'], equals('pi_test_001'));
        expect(result[0]['amount'], equals(2599));
        expect(result[1]['payment_intent_id'], equals('pi_test_002'));

        verify(mockClient.from('payments')).called(1);
        verify(mockQueryBuilder.select('*, orders!inner(user_id)')).called(1);
        verify(mockFilterBuilder.eq('orders.user_id', userId)).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        // Arrange
        final String userId = 'network-error-user';
        
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', userId)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('created_at', ascending: false))
            .thenThrow(Exception('Network connection failed'));

        // Act & Assert
        expect(() async => await apiService.fetchUserOrders(userId),
               throwsA(isA<Exception>()));
      });

      test('should validate input parameters', () async {
        // Act & Assert - Empty user ID
        expect(() async => await apiService.fetchUserOrders(''),
               throwsA(isA<ArgumentError>()));

        // Invalid order ID
        expect(() async => await apiService.fetchOrderById(-1),
               throwsA(isA<ArgumentError>()));

        // Invalid hike purchase parameters
        expect(() async => await apiService.hasUserPurchasedHike('', 1),
               throwsA(isA<ArgumentError>()));
        
        expect(() async => await apiService.hasUserPurchasedHike('user', 0),
               throwsA(isA<ArgumentError>()));
      });
    });
  });
}

// RED PHASE IMPLEMENTATION NOTES:
// ❌ Tests are failing (expected) - BackendApiService methods don't exist yet
// 🔍 Test Coverage:
// - fetchUserOrders() - Get orders for specific user with proper sorting
// - fetchOrderById() - Get single order with all details  
// - hasUserPurchasedHike() - Check if user owns a hike
// - recordHikePurchase() - Record successful purchase
// - fetchOrderWithPaymentDetails() - Order with payment information
// - updateOrderAfterPayment() - Update order status post-payment
// - getUserPaymentHistory() - Payment history with JOIN queries
// - Error handling and input validation
//
// NEXT: GREEN PHASE - Implement the methods to make tests pass