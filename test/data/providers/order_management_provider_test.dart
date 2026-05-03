import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:whisky_hikes/data/providers/order_management_provider.dart';
import 'package:whisky_hikes/data/services/admin/order_management_service.dart';
import '../test_helpers.dart';

@GenerateMocks([OrderManagementService])
import 'order_management_provider_test.mocks.dart';

void main() {
  group('OrderManagementProvider Tests', () {
    late OrderManagementProvider provider;
    late MockOrderManagementService mockService;

    setUp(() {
      mockService = MockOrderManagementService();
      provider = OrderManagementProvider(orderManagementService: mockService);
    });

    group('State Management', () {
      test('should initialize with correct default values', () {
        // Assert
        expect(provider.orders, isEmpty);
        expect(provider.selectedOrder, isNull);
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.filteredOrders, isEmpty);
        expect(provider.currentFilter, equals('all'));
        expect(provider.searchTerm, isEmpty);
      });

      test('should set loading state correctly', () {
        // Act
        provider.setLoading(true);

        // Assert
        expect(provider.isLoading, isTrue);

        // Act
        provider.setLoading(false);

        // Assert
        expect(provider.isLoading, isFalse);
      });

      test('should set error message correctly', () {
        // Arrange
        const errorMessage = 'Test error message';

        // Act
        provider.setError(errorMessage);

        // Assert
        expect(provider.errorMessage, equals(errorMessage));
      });

      test('should clear error message', () {
        // Arrange
        provider.setError('Test error');

        // Act
        provider.clearError();

        // Assert
        expect(provider.errorMessage, isNull);
      });
    });

    group('Order Management', () {
      test('should load orders successfully', () async {
        // Arrange
        final ordersData = [
          TestHelpers.createTestBasicOrderJson(id: 1, userId: 'user1'),
          TestHelpers.createTestBasicOrderJson(id: 2, userId: 'user2'),
        ];

        when(
          mockService.getAllOrdersForAdmin(),
        ).thenAnswer((_) async => ordersData);

        // Act
        await provider.loadOrders();

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.orders.length, equals(2));
        expect(provider.orders, equals(ordersData));
        verify(mockService.getAllOrdersForAdmin()).called(1);
      });

      test('should handle load orders error', () async {
        // Arrange
        when(
          mockService.getAllOrdersForAdmin(),
        ).thenThrow(Exception('Network error'));

        // Act
        await provider.loadOrders();

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, contains('Network error'));
        expect(provider.orders, isEmpty);
        verify(mockService.getAllOrdersForAdmin()).called(1);
      });

      test('should create order successfully', () async {
        // Arrange
        final orderData = {
          'user_id': 'user123',
          'hike_id': 1,
          'total_amount': 49.99,
          'status': 'pending',
        };
        final createdOrder = TestHelpers.createTestBasicOrderJson(
          id: 1,
          userId: 'user123',
          hikeId: 1,
        );

        when(mockService.validateOrderData(orderData)).thenReturn(true);
        when(
          mockService.createOrder(orderData),
        ).thenAnswer((_) async => createdOrder);
        when(
          mockService.getAllOrdersForAdmin(),
        ).thenAnswer((_) async => [createdOrder]);

        // Act
        await provider.createOrder(orderData);

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.orders.length, equals(1));
        expect(provider.orders[0]['id'], equals(1));
        verify(mockService.createOrder(orderData)).called(1);
        verify(mockService.getAllOrdersForAdmin()).called(1);
      });

      test('should handle create order error', () async {
        // Arrange
        final orderData = {
          'user_id': 'user123',
          'hike_id': 1,
          'total_amount': 49.99,
          'status': 'pending',
        };

        when(mockService.validateOrderData(orderData)).thenReturn(true);
        when(
          mockService.createOrder(orderData),
        ).thenThrow(Exception('Failed to create order'));

        // Act
        await provider.createOrder(orderData);

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, contains('Failed to create order'));
        verify(mockService.createOrder(orderData)).called(1);
      });

      test('should update order successfully', () async {
        // Arrange
        const orderId = 123;
        final updateData = {'status': 'processing'};
        final updatedOrder = TestHelpers.createTestBasicOrderJson(
          id: orderId,
          userId: 'user123',
          status: 'processing',
        );

        when(mockService.validateUpdateData(updateData)).thenReturn(true);
        when(
          mockService.updateOrder(orderId, updateData),
        ).thenAnswer((_) async => updatedOrder);
        when(
          mockService.getAllOrdersForAdmin(),
        ).thenAnswer((_) async => [updatedOrder]);

        // Act
        await provider.updateOrder(orderId, updateData);

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        verify(mockService.updateOrder(orderId, updateData)).called(1);
        verify(mockService.getAllOrdersForAdmin()).called(1);
      });

      test('should delete order successfully', () async {
        // Arrange
        const orderId = 123;
        final initialOrder = TestHelpers.createTestBasicOrderJson(
          id: orderId,
          userId: 'user123',
        );

        // Setup initial state
        provider.orders.add(initialOrder);

        when(mockService.deleteOrder(orderId)).thenAnswer((_) async => {});

        // Act
        await provider.deleteOrder(orderId);

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.orders, isEmpty);
        verify(mockService.deleteOrder(orderId)).called(1);
      });

      test('should select order and load details', () async {
        // Arrange
        final orderData = TestHelpers.createTestBasicOrderJson(
          id: 123,
          userId: 'user123',
        );

        when(mockService.getOrderById(123)).thenAnswer((_) async => orderData);

        // Act
        await provider.selectOrder(orderData);

        // Assert
        expect(provider.selectedOrder, equals(orderData));
        verify(mockService.getOrderById(123)).called(1);
      });

      test('should deselect order', () {
        // Arrange
        final orderData = TestHelpers.createTestBasicOrderJson(
          id: 123,
          userId: 'user123',
        );
        provider.selectedOrder = orderData;

        // Act
        provider.deselectOrder();

        // Assert
        expect(provider.selectedOrder, isNull);
      });
    });

    group('Order Status Management', () {
      test('should update order status successfully', () async {
        // Arrange
        const orderId = 123;
        const newStatus = 'shipped';
        final updatedOrder = TestHelpers.createTestBasicOrderJson(
          id: orderId,
          userId: 'user123',
          status: newStatus,
        );

        when(mockService.validateOrderStatus(newStatus)).thenReturn(true);
        when(
          mockService.updateOrderStatus(orderId, newStatus),
        ).thenAnswer((_) async => updatedOrder);
        when(
          mockService.getAllOrdersForAdmin(),
        ).thenAnswer((_) async => [updatedOrder]);

        // Act
        await provider.updateOrderStatus(orderId, newStatus);

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        verify(mockService.updateOrderStatus(orderId, newStatus)).called(1);
        verify(mockService.getAllOrdersForAdmin()).called(1);
      });

      test('should validate status before update', () async {
        // Arrange
        const orderId = 123;
        const invalidStatus = 'invalid_status';

        when(mockService.validateOrderStatus(invalidStatus)).thenReturn(false);

        // Act
        await provider.updateOrderStatus(orderId, invalidStatus);

        // Assert
        expect(provider.errorMessage, contains('Invalid order status'));
        verifyNever(mockService.updateOrderStatus(any, any));
      });

      test('should get valid order statuses', () {
        // Arrange
        final validStatuses = [
          'pending',
          'confirmed',
          'processing',
          'shipped',
          'delivered',
          'cancelled',
        ];
        when(mockService.getValidStatuses()).thenReturn(validStatuses);

        // Act
        final result = provider.getValidOrderStatuses();

        // Assert
        expect(result, equals(validStatuses));
        verify(mockService.getValidStatuses()).called(1);
      });
    });

    group('Filtering and Search', () {
      test('should filter orders by status', () async {
        // Arrange
        final orders = [
          TestHelpers.createTestBasicOrderJson(
            id: 1,
            userId: 'user1',
            status: 'pending',
          ),
          TestHelpers.createTestBasicOrderJson(
            id: 2,
            userId: 'user2',
            status: 'shipped',
          ),
          TestHelpers.createTestBasicOrderJson(
            id: 3,
            userId: 'user3',
            status: 'pending',
          ),
        ];

        when(
          mockService.getOrdersByStatus('pending'),
        ).thenAnswer((_) async => [orders[0], orders[2]]);

        // Act
        await provider.filterOrdersByStatus('pending');

        // Assert
        expect(provider.currentFilter, equals('pending'));
        expect(provider.filteredOrders.length, equals(2));
        expect(provider.filteredOrders[0]['status'], equals('pending'));
        expect(provider.filteredOrders[1]['status'], equals('pending'));
        verify(mockService.getOrdersByStatus('pending')).called(1);
      });

      test('should search orders by term', () async {
        // Arrange
        const searchTerm = '123';
        final orders = [
          TestHelpers.createTestBasicOrderJson(id: 123, userId: 'user1'),
        ];

        when(
          mockService.searchOrders(searchTerm),
        ).thenAnswer((_) async => orders);

        // Act
        await provider.searchOrders(searchTerm);

        // Assert
        expect(provider.searchTerm, equals(searchTerm));
        expect(provider.filteredOrders, equals(orders));
        verify(mockService.searchOrders(searchTerm)).called(1);
      });

      test('should filter orders by date range', () async {
        // Arrange
        final startDate = DateTime.now().subtract(Duration(days: 7));
        final endDate = DateTime.now();
        final orders = [
          TestHelpers.createTestBasicOrderJson(id: 1, userId: 'user1'),
        ];

        when(
          mockService.getOrdersByDateRange(startDate, endDate),
        ).thenAnswer((_) async => orders);

        // Act
        await provider.filterOrdersByDateRange(startDate, endDate);

        // Assert
        expect(provider.filteredOrders, equals(orders));
        verify(mockService.getOrdersByDateRange(startDate, endDate)).called(1);
      });

      test('should clear all filters', () async {
        // Arrange
        final allOrders = [
          TestHelpers.createTestBasicOrderJson(id: 1, userId: 'user1'),
          TestHelpers.createTestBasicOrderJson(id: 2, userId: 'user2'),
        ];

        when(
          mockService.getAllOrdersForAdmin(),
        ).thenAnswer((_) async => allOrders);

        // Set some filters first
        provider.currentFilter = 'pending';
        provider.searchTerm = 'test';

        // Act
        await provider.clearFilters();

        // Assert
        expect(provider.currentFilter, equals('all'));
        expect(provider.searchTerm, isEmpty);
        expect(provider.filteredOrders, equals(allOrders));
        verify(mockService.getAllOrdersForAdmin()).called(1);
      });
    });

    group('Order Statistics', () {
      test('should load order statistics successfully', () async {
        // Arrange
        final stats = {
          'totalOrders': 10,
          'totalRevenue': 500.0,
          'averageOrderValue': 50.0,
          'pendingOrders': 3,
          'completedOrders': 7,
        };

        when(mockService.getOrderStatistics()).thenAnswer((_) async => stats);

        // Act
        await provider.loadOrderStatistics();

        // Assert
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.orderStatistics, equals(stats));
        verify(mockService.getOrderStatistics()).called(1);
      });

      test('should load recent orders successfully', () async {
        // Arrange
        const limit = 5;
        final recentOrders = [
          TestHelpers.createTestBasicOrderJson(id: 1, userId: 'user1'),
          TestHelpers.createTestBasicOrderJson(id: 2, userId: 'user2'),
        ];

        when(
          mockService.getRecentOrders(limit: limit),
        ).thenAnswer((_) async => recentOrders);

        // Act
        await provider.loadRecentOrders(limit: limit);

        // Assert
        expect(provider.recentOrders, equals(recentOrders));
        verify(mockService.getRecentOrders(limit: limit)).called(1);
      });
    });

    group('Sorting', () {
      test('should sort orders by different criteria', () {
        // Arrange
        final orders = [
          TestHelpers.createTestBasicOrderJson(
            id: 2,
            userId: 'user2',
            totalAmount: 30.0,
          ),
          TestHelpers.createTestBasicOrderJson(
            id: 1,
            userId: 'user1',
            totalAmount: 50.0,
          ),
          TestHelpers.createTestBasicOrderJson(
            id: 3,
            userId: 'user3',
            totalAmount: 20.0,
          ),
        ];
        provider.orders.addAll(orders);

        // Act
        final sortedByAmount = provider.sortOrders(
          'total_amount',
          ascending: false,
        );

        // Assert
        expect(sortedByAmount[0]['total_amount'], equals(50.0));
        expect(sortedByAmount[1]['total_amount'], equals(30.0));
        expect(sortedByAmount[2]['total_amount'], equals(20.0));
      });

      test('should sort by creation date', () {
        // Arrange
        final now = DateTime.now();
        final orders = [
          TestHelpers.createTestBasicOrderJson(
            id: 2,
            userId: 'user2',
            totalAmount: 30.0,
          ),
          TestHelpers.createTestBasicOrderJson(
            id: 1,
            userId: 'user1',
            totalAmount: 50.0,
          ),
        ];
        orders[0]['created_at'] = now
            .subtract(Duration(hours: 1))
            .toIso8601String();
        orders[1]['created_at'] = now.toIso8601String();
        provider.orders.addAll(orders);

        // Act
        final sortedByDate = provider.sortOrders(
          'created_at',
          ascending: false,
        );

        // Assert
        expect(sortedByDate[0]['id'], equals(1)); // Most recent first
        expect(sortedByDate[1]['id'], equals(2));
      });
    });

    group('Error Recovery', () {
      test('should clear error when starting new operation', () async {
        // Arrange
        provider.setError('Previous error');
        when(mockService.getAllOrdersForAdmin()).thenAnswer((_) async => []);

        // Act
        await provider.loadOrders();

        // Assert
        expect(provider.errorMessage, isNull);
      });

      test('should retry failed operations', () async {
        // Arrange
        int callCount = 0;
        when(mockService.getAllOrdersForAdmin()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          } else {
            return [];
          }
        });

        // Act - First call fails
        await provider.loadOrders();
        expect(provider.errorMessage, isNotNull);

        // Act - Retry succeeds
        await provider.loadOrders();

        // Assert
        expect(provider.errorMessage, isNull);
        expect(provider.orders, isEmpty);
        verify(mockService.getAllOrdersForAdmin()).called(2);
      });
    });

    group('Data Management', () {
      test('should calculate order statistics locally', () {
        // Arrange
        final orders = [
          TestHelpers.createTestBasicOrderJson(
            id: 1,
            userId: 'user1',
            status: 'pending',
            totalAmount: 50.0,
          ),
          TestHelpers.createTestBasicOrderJson(
            id: 2,
            userId: 'user2',
            status: 'shipped',
            totalAmount: 30.0,
          ),
          TestHelpers.createTestBasicOrderJson(
            id: 3,
            userId: 'user3',
            status: 'delivered',
            totalAmount: 20.0,
          ),
        ];
        provider.orders.addAll(orders);

        // Setup mocks for status checking
        when(mockService.isPendingStatus('pending')).thenReturn(true);
        when(mockService.isPendingStatus('shipped')).thenReturn(false);
        when(mockService.isPendingStatus('delivered')).thenReturn(false);
        when(mockService.isCompletedStatus('pending')).thenReturn(false);
        when(mockService.isCompletedStatus('shipped')).thenReturn(true);
        when(mockService.isCompletedStatus('delivered')).thenReturn(true);

        // Act
        final stats = provider.calculateLocalStatistics();

        // Assert
        expect(stats['totalOrders'], equals(3));
        expect(stats['totalRevenue'], equals(100.0));
        expect(stats['averageOrderValue'], closeTo(33.33, 0.01));
        expect(stats['pendingOrders'], equals(1));
        expect(stats['completedOrders'], equals(2));
      });

      test('should refresh data', () async {
        // Arrange
        final orders = [
          TestHelpers.createTestBasicOrderJson(id: 1, userId: 'user1'),
        ];

        when(
          mockService.getAllOrdersForAdmin(),
        ).thenAnswer((_) async => orders);

        // Act
        await provider.refreshData();

        // Assert
        expect(provider.orders, equals(orders));
        verify(mockService.getAllOrdersForAdmin()).called(1);
      });

      test('should clear all data', () {
        // Arrange
        provider.orders.addAll([
          TestHelpers.createTestBasicOrderJson(id: 1, userId: 'user1'),
        ]);
        provider.selectedOrder = TestHelpers.createTestBasicOrderJson(
          id: 1,
          userId: 'user1',
        );
        provider.setError('Test error');

        // Act
        provider.clearData();

        // Assert
        expect(provider.orders, isEmpty);
        expect(provider.selectedOrder, isNull);
        expect(provider.errorMessage, isNull);
        expect(provider.currentFilter, equals('all'));
        expect(provider.searchTerm, isEmpty);
      });
    });

    group('Helper Methods', () {
      test('should check if order can be modified', () {
        // Arrange
        final pendingOrder = TestHelpers.createTestBasicOrderJson(
          id: 1,
          userId: 'user1',
          status: 'pending',
        );
        final shippedOrder = TestHelpers.createTestBasicOrderJson(
          id: 2,
          userId: 'user2',
          status: 'shipped',
        );

        when(mockService.isPendingStatus('pending')).thenReturn(true);
        when(mockService.isPendingStatus('shipped')).thenReturn(false);

        // Act & Assert
        expect(provider.canModifyOrder(pendingOrder), isTrue);
        expect(provider.canModifyOrder(shippedOrder), isFalse);
      });

      test('should format order amount', () {
        // Arrange
        final order = TestHelpers.createTestBasicOrderJson(
          id: 1,
          userId: 'user1',
          totalAmount: 49.99,
        );

        // Act
        final formatted = provider.formatOrderAmount(order);

        // Assert
        expect(formatted, equals('€49.99'));
      });

      test('should get order status color', () {
        // Act & Assert
        expect(provider.getOrderStatusColor('pending'), isNotNull);
        expect(provider.getOrderStatusColor('confirmed'), isNotNull);
        expect(provider.getOrderStatusColor('processing'), isNotNull);
        expect(provider.getOrderStatusColor('shipped'), isNotNull);
        expect(provider.getOrderStatusColor('delivered'), isNotNull);
        expect(provider.getOrderStatusColor('cancelled'), isNotNull);
      });
    });
  });
}
