import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/admin/order_management_service.dart';
import '../../test_helpers.dart';

// Generate mocks for dependencies
@GenerateMocks([
  SupabaseClient,
  SupabaseQueryBuilder,
  PostgrestFilterBuilder,
  PostgrestTransformBuilder,
])
import 'order_management_service_test.mocks.dart';

void main() {
  group('OrderManagementService Tests', () {
    late OrderManagementService service;
    late MockSupabaseClient mockClient;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;
    late MockPostgrestTransformBuilder mockTransformBuilder;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      mockTransformBuilder = MockPostgrestTransformBuilder();

      service = OrderManagementService(client: mockClient);
    });

    group('Order CRUD Operations', () {
      test('getAllOrdersForAdmin should return list of orders', () async {
        // Arrange
        final orderData = [
          TestHelpers.createTestBasicOrderJson(id: 1, userId: 'user1'),
          TestHelpers.createTestBasicOrderJson(id: 2, userId: 'user2'),
        ];

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockTransformBuilder);
        when(mockQueryBuilder.order('created_at', ascending: false))
            .thenReturn(mockQueryBuilder);
        when(mockTransformBuilder.order('created_at', ascending: false))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then())
            .thenAnswer((_) async => orderData);

        // Act
        final result = await service.getAllOrdersForAdmin();

        // Assert
        expect(result, equals(orderData));
        verify(mockClient.from('orders')).called(1);
      });

      test('getOrderById should return specific order', () async {
        // Arrange
        const orderId = 123;
        final orderData = TestHelpers.createTestBasicOrderJson(
          id: orderId,
          userId: 'user123'
        );

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', orderId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => orderData);

        // Act
        final result = await service.getOrderById(orderId);

        // Assert
        expect(result, equals(orderData));
        verify(mockClient.from('orders')).called(1);
        verify(mockFilterBuilder.eq('id', orderId)).called(1);
      });

      test('createOrder should create new order successfully', () async {
        // Arrange
        final orderData = {
          'user_id': 'user123',
          'hike_id': 1,
          'status': 'pending',
          'total_amount': 49.99,
        };
        final createdOrder = TestHelpers.createTestBasicOrderJson(
          id: 1,
          userId: 'user123',
          hikeId: 1,
        );

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(orderData)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => createdOrder);

        // Act
        final result = await service.createOrder(orderData);

        // Assert
        expect(result, equals(createdOrder));
        verify(mockClient.from('orders')).called(1);
        verify(mockQueryBuilder.insert(orderData)).called(1);
      });

      test('updateOrder should update existing order', () async {
        // Arrange
        const orderId = 123;
        final updateData = {'status': 'processing'};
        final updatedOrder = TestHelpers.createTestBasicOrderJson(
          id: orderId,
          userId: 'user123',
          status: 'processing',
        );

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(updateData)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', orderId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => updatedOrder);

        // Act
        final result = await service.updateOrder(orderId, updateData);

        // Assert
        expect(result, equals(updatedOrder));
        verify(mockClient.from('orders')).called(1);
        verify(mockFilterBuilder.eq('id', orderId)).called(1);
      });

      test('deleteOrder should delete order successfully', () async {
        // Arrange
        const orderId = 123;

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', orderId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenAnswer((_) async => {});

        // Act
        await service.deleteOrder(orderId);

        // Assert
        verify(mockClient.from('orders')).called(1);
        verify(mockFilterBuilder.eq('id', orderId)).called(1);
      });
    });

    group('Order Status Management', () {
      test('updateOrderStatus should update order status', () async {
        // Arrange
        const orderId = 123;
        const newStatus = 'shipped';
        final updatedOrder = TestHelpers.createTestBasicOrderJson(
          id: orderId,
          userId: 'user123',
          status: newStatus,
        );

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update({'status': newStatus}))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', orderId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => updatedOrder);

        // Act
        final result = await service.updateOrderStatus(orderId, newStatus);

        // Assert
        expect(result, equals(updatedOrder));
        expect(result['status'], equals(newStatus));
        verify(mockQueryBuilder.update({'status': newStatus})).called(1);
      });

      test('getOrdersByStatus should filter orders by status', () async {
        // Arrange
        const status = 'pending';
        final orderData = [
          TestHelpers.createTestBasicOrderJson(id: 1, userId: 'user1', status: status),
          TestHelpers.createTestBasicOrderJson(id: 2, userId: 'user2', status: status),
        ];

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('status', status)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenAnswer((_) async => orderData);

        // Act
        final result = await service.getOrdersByStatus(status);

        // Assert
        expect(result, equals(orderData));
        verify(mockFilterBuilder.eq('status', status)).called(1);
      });

      test('validateOrderStatus should validate valid status', () async {
        // Act & Assert
        expect(service.validateOrderStatus('pending'), isTrue);
        expect(service.validateOrderStatus('confirmed'), isTrue);
        expect(service.validateOrderStatus('processing'), isTrue);
        expect(service.validateOrderStatus('shipped'), isTrue);
        expect(service.validateOrderStatus('delivered'), isTrue);
        expect(service.validateOrderStatus('cancelled'), isTrue);
        expect(service.validateOrderStatus('invalid_status'), isFalse);
      });
    });

    group('Order Filtering and Search', () {
      test('searchOrders should search by order ID', () async {
        // Arrange
        const searchTerm = '123';
        final orderData = [
          TestHelpers.createTestBasicOrderJson(id: 123, userId: 'user1'),
        ];

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.ilike('id', '%$searchTerm%')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenAnswer((_) async => orderData);

        // Act
        final result = await service.searchOrders(searchTerm);

        // Assert
        expect(result, equals(orderData));
        verify(mockFilterBuilder.ilike('id', '%$searchTerm%')).called(1);
      });

      test('getOrdersByDateRange should filter orders by date', () async {
        // Arrange
        final startDate = DateTime.now().subtract(Duration(days: 7));
        final endDate = DateTime.now();
        final orderData = [
          TestHelpers.createTestBasicOrderJson(id: 1, userId: 'user1'),
        ];

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.gte('created_at', startDate.toIso8601String()))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.lte('created_at', endDate.toIso8601String()))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenAnswer((_) async => orderData);

        // Act
        final result = await service.getOrdersByDateRange(startDate, endDate);

        // Assert
        expect(result, equals(orderData));
        verify(mockFilterBuilder.gte('created_at', startDate.toIso8601String())).called(1);
        verify(mockFilterBuilder.lte('created_at', endDate.toIso8601String())).called(1);
      });

      test('getOrdersByUser should filter orders by user ID', () async {
        // Arrange
        const userId = 'user123';
        final orderData = [
          TestHelpers.createTestBasicOrderJson(id: 1, userId: userId),
          TestHelpers.createTestBasicOrderJson(id: 2, userId: userId),
        ];

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('user_id', userId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenAnswer((_) async => orderData);

        // Act
        final result = await service.getOrdersByUser(userId);

        // Assert
        expect(result, equals(orderData));
        verify(mockFilterBuilder.eq('user_id', userId)).called(1);
      });
    });

    group('Order Statistics', () {
      test('getOrderStatistics should return order stats', () async {
        // Arrange
        final orders = [
          TestHelpers.createTestBasicOrderJson(id: 1, userId: 'user1', status: 'pending', totalAmount: 49.99),
          TestHelpers.createTestBasicOrderJson(id: 2, userId: 'user2', status: 'shipped', totalAmount: 59.99),
          TestHelpers.createTestBasicOrderJson(id: 3, userId: 'user3', status: 'delivered', totalAmount: 39.99),
        ];

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then()).thenAnswer((_) async => orders);

        // Act
        final result = await service.getOrderStatistics();

        // Assert
        expect(result['totalOrders'], equals(3));
        expect(result['totalRevenue'], equals(149.97));
        expect(result['averageOrderValue'], equals(49.99));
        expect(result['pendingOrders'], equals(1));
        expect(result['completedOrders'], equals(2));
      });

      test('getRecentOrders should return recent orders with limit', () async {
        // Arrange
        const limit = 5;
        final orderData = [
          TestHelpers.createTestBasicOrderJson(id: 1, userId: 'user1'),
          TestHelpers.createTestBasicOrderJson(id: 2, userId: 'user2'),
        ];

        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('created_at', ascending: false))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.limit(limit)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then()).thenAnswer((_) async => orderData);

        // Act
        final result = await service.getRecentOrders(limit: limit);

        // Assert
        expect(result, equals(orderData));
        verify(mockTransformBuilder.limit(limit)).called(1);
      });
    });

    group('Data Validation', () {
      test('validateOrderData should validate required fields', () async {
        // Arrange
        final validOrderData = {
          'user_id': 'user123',
          'hike_id': 1,
          'total_amount': 49.99,
          'status': 'pending',
        };

        final invalidOrderData = {
          'user_id': '',
          'hike_id': null,
        };

        // Act & Assert
        expect(service.validateOrderData(validOrderData), isTrue);
        expect(service.validateOrderData(invalidOrderData), isFalse);
      });

      test('validateUpdateData should validate update fields', () async {
        // Arrange
        final validUpdateData = {
          'status': 'processing',
          'tracking_number': 'TRACK123',
        };

        final invalidUpdateData = {
          'status': 'invalid_status',
        };

        // Act & Assert
        expect(service.validateUpdateData(validUpdateData), isTrue);
        expect(service.validateUpdateData(invalidUpdateData), isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        // Arrange
        when(mockClient.from('orders')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.then()).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(() => service.getAllOrdersForAdmin(), throwsException);
      });

      test('should handle database errors gracefully', () async {
        // Arrange
        when(mockClient.from('orders')).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(() => service.getOrderById(123), throwsException);
      });
    });
  });
}