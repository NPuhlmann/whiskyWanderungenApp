import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/admin/order_management_service.dart';
import '../../test_helpers.dart';

// Mock classes for testing
@GenerateMocks([SupabaseClient])
import 'order_management_service_simple_test.mocks.dart';

void main() {
  group('OrderManagementService - Basic Tests', () {
    late OrderManagementService service;
    late MockSupabaseClient mockClient;

    setUp(() {
      mockClient = MockSupabaseClient();
      service = OrderManagementService(client: mockClient);
    });

    group('Data Validation', () {
      test('validateOrderData should validate required fields', () {
        // Arrange
        final validOrderData = {
          'user_id': 'user123',
          'hike_id': 1,
          'total_amount': 49.99,
          'status': 'pending',
        };

        final invalidOrderDataEmpty = <String, dynamic>{};

        final invalidOrderDataMissingUserId = {
          'hike_id': 1,
          'total_amount': 49.99,
          'status': 'pending',
        };

        final invalidOrderDataEmptyUserId = {
          'user_id': '',
          'hike_id': 1,
          'total_amount': 49.99,
          'status': 'pending',
        };

        final invalidOrderDataMissingHikeId = {
          'user_id': 'user123',
          'total_amount': 49.99,
          'status': 'pending',
        };

        final invalidOrderDataZeroAmount = {
          'user_id': 'user123',
          'hike_id': 1,
          'total_amount': 0,
          'status': 'pending',
        };

        final invalidOrderDataNegativeAmount = {
          'user_id': 'user123',
          'hike_id': 1,
          'total_amount': -10.0,
          'status': 'pending',
        };

        final invalidOrderDataInvalidStatus = {
          'user_id': 'user123',
          'hike_id': 1,
          'total_amount': 49.99,
          'status': 'invalid_status',
        };

        // Act & Assert
        expect(service.validateOrderData(validOrderData), isTrue);
        expect(service.validateOrderData(invalidOrderDataEmpty), isFalse);
        expect(
          service.validateOrderData(invalidOrderDataMissingUserId),
          isFalse,
        );
        expect(service.validateOrderData(invalidOrderDataEmptyUserId), isFalse);
        expect(
          service.validateOrderData(invalidOrderDataMissingHikeId),
          isFalse,
        );
        expect(service.validateOrderData(invalidOrderDataZeroAmount), isFalse);
        expect(
          service.validateOrderData(invalidOrderDataNegativeAmount),
          isFalse,
        );
        expect(
          service.validateOrderData(invalidOrderDataInvalidStatus),
          isFalse,
        );
      });

      test('validateUpdateData should validate update fields', () {
        // Arrange
        final validUpdateData = {
          'status': 'processing',
          'tracking_number': 'TRACK123',
        };

        final validUpdateDataMinimal = {'status': 'shipped'};

        final validUpdateDataAmount = {'total_amount': 59.99};

        final invalidUpdateDataStatus = {'status': 'invalid_status'};

        final invalidUpdateDataZeroAmount = {'total_amount': 0};

        final invalidUpdateDataNegativeAmount = {'total_amount': -5.0};

        // Act & Assert
        expect(service.validateUpdateData(validUpdateData), isTrue);
        expect(service.validateUpdateData(validUpdateDataMinimal), isTrue);
        expect(service.validateUpdateData(validUpdateDataAmount), isTrue);
        expect(service.validateUpdateData(invalidUpdateDataStatus), isFalse);
        expect(
          service.validateUpdateData(invalidUpdateDataZeroAmount),
          isFalse,
        );
        expect(
          service.validateUpdateData(invalidUpdateDataNegativeAmount),
          isFalse,
        );
      });

      test('validateOrderStatus should validate all valid statuses', () {
        // Act & Assert
        expect(service.validateOrderStatus('pending'), isTrue);
        expect(service.validateOrderStatus('confirmed'), isTrue);
        expect(service.validateOrderStatus('processing'), isTrue);
        expect(service.validateOrderStatus('shipped'), isTrue);
        expect(service.validateOrderStatus('delivered'), isTrue);
        expect(service.validateOrderStatus('cancelled'), isTrue);

        // Invalid statuses
        expect(service.validateOrderStatus('invalid'), isFalse);
        expect(service.validateOrderStatus(''), isFalse);
        expect(
          service.validateOrderStatus('PENDING'),
          isFalse,
        ); // Case sensitive
        expect(service.validateOrderStatus('active'), isFalse);
        expect(service.validateOrderStatus('complete'), isFalse);
      });
    });

    group('Status Helper Methods', () {
      test('getValidStatuses should return all valid statuses', () {
        // Act
        final statuses = service.getValidStatuses();

        // Assert
        expect(statuses, contains('pending'));
        expect(statuses, contains('confirmed'));
        expect(statuses, contains('processing'));
        expect(statuses, contains('shipped'));
        expect(statuses, contains('delivered'));
        expect(statuses, contains('cancelled'));
        expect(statuses.length, equals(6));
      });

      test('isCompletedStatus should identify completed statuses', () {
        // Act & Assert
        expect(service.isCompletedStatus('shipped'), isTrue);
        expect(service.isCompletedStatus('delivered'), isTrue);

        expect(service.isCompletedStatus('pending'), isFalse);
        expect(service.isCompletedStatus('confirmed'), isFalse);
        expect(service.isCompletedStatus('processing'), isFalse);
        expect(service.isCompletedStatus('cancelled'), isFalse);
      });

      test('isPendingStatus should identify pending statuses', () {
        // Act & Assert
        expect(service.isPendingStatus('pending'), isTrue);
        expect(service.isPendingStatus('confirmed'), isTrue);
        expect(service.isPendingStatus('processing'), isTrue);

        expect(service.isPendingStatus('shipped'), isFalse);
        expect(service.isPendingStatus('delivered'), isFalse);
        expect(service.isPendingStatus('cancelled'), isFalse);
      });

      test('isCancelledStatus should identify cancelled status', () {
        // Act & Assert
        expect(service.isCancelledStatus('cancelled'), isTrue);

        expect(service.isCancelledStatus('pending'), isFalse);
        expect(service.isCancelledStatus('confirmed'), isFalse);
        expect(service.isCancelledStatus('processing'), isFalse);
        expect(service.isCancelledStatus('shipped'), isFalse);
        expect(service.isCancelledStatus('delivered'), isFalse);
      });
    });

    group('Service Initialization', () {
      test('should initialize without errors', () {
        // Act & Assert
        expect(
          () => OrderManagementService(client: mockClient),
          returnsNormally,
        );
      });

      test('should accept custom client', () {
        // Arrange
        final customClient = MockSupabaseClient();

        // Act & Assert
        expect(
          () => OrderManagementService(client: customClient),
          returnsNormally,
        );
      });
    });

    group('TestHelpers Integration', () {
      test('should work with TestHelpers order data', () {
        // Arrange
        final orderData = TestHelpers.createTestBasicOrderJson(
          id: 1,
          userId: 'user123',
          hikeId: 1,
          status: 'pending',
          totalAmount: 49.99,
        );

        // Remove id for validation (as it's auto-generated)
        final createData = Map<String, dynamic>.from(orderData);
        createData.remove('id');
        createData.remove('created_at');
        createData.remove('updated_at');

        // Act & Assert
        expect(service.validateOrderData(createData), isTrue);
        expect(service.validateOrderStatus(orderData['status']), isTrue);
      });

      test('should validate various TestHelper order configurations', () {
        // Arrange & Act & Assert
        final orders = [
          TestHelpers.createTestBasicOrderJson(
            id: 1,
            userId: 'user1',
            status: 'pending',
          ),
          TestHelpers.createTestBasicOrderJson(
            id: 2,
            userId: 'user2',
            status: 'confirmed',
          ),
          TestHelpers.createTestBasicOrderJson(
            id: 3,
            userId: 'user3',
            status: 'processing',
          ),
          TestHelpers.createTestBasicOrderJson(
            id: 4,
            userId: 'user4',
            status: 'shipped',
          ),
          TestHelpers.createTestBasicOrderJson(
            id: 5,
            userId: 'user5',
            status: 'delivered',
          ),
          TestHelpers.createTestBasicOrderJson(
            id: 6,
            userId: 'user6',
            status: 'cancelled',
          ),
        ];

        for (final order in orders) {
          expect(
            service.validateOrderStatus(order['status']),
            isTrue,
            reason: 'Status ${order['status']} should be valid',
          );
        }
      });
    });

    group('Business Logic Validation', () {
      test('should validate order workflow transitions', () {
        // Act & Assert - Valid transitions
        expect(service.validateOrderStatus('pending'), isTrue);
        expect(service.validateOrderStatus('confirmed'), isTrue);
        expect(service.validateOrderStatus('processing'), isTrue);
        expect(service.validateOrderStatus('shipped'), isTrue);
        expect(service.validateOrderStatus('delivered'), isTrue);

        // Cancellation can happen at any time
        expect(service.validateOrderStatus('cancelled'), isTrue);
      });

      test('should categorize order statuses correctly for business logic', () {
        // Pending orders (can be modified)
        expect(service.isPendingStatus('pending'), isTrue);
        expect(service.isPendingStatus('confirmed'), isTrue);
        expect(service.isPendingStatus('processing'), isTrue);

        // Completed orders (cannot be modified)
        expect(service.isCompletedStatus('shipped'), isTrue);
        expect(service.isCompletedStatus('delivered'), isTrue);

        // Cancelled orders (special case)
        expect(service.isCancelledStatus('cancelled'), isTrue);
      });

      test('should provide correct status categories for UI', () {
        final validStatuses = service.getValidStatuses();

        // Count categories
        int pendingCount = 0;
        int completedCount = 0;
        int cancelledCount = 0;

        for (final status in validStatuses) {
          if (service.isPendingStatus(status)) pendingCount++;
          if (service.isCompletedStatus(status)) completedCount++;
          if (service.isCancelledStatus(status)) cancelledCount++;
        }

        expect(pendingCount, equals(3)); // pending, confirmed, processing
        expect(completedCount, equals(2)); // shipped, delivered
        expect(cancelledCount, equals(1)); // cancelled
      });
    });

    group('Data Integrity', () {
      test('validateOrderData should handle edge cases', () {
        // Null data
        expect(service.validateOrderData({}), isFalse);

        // String numbers
        final stringNumberData = {
          'user_id': 'user123',
          'hike_id': '1', // String instead of int
          'total_amount': '49.99', // String instead of double
          'status': 'pending',
        };
        expect(service.validateOrderData(stringNumberData), isTrue);

        // Very large amounts
        final largeAmountData = {
          'user_id': 'user123',
          'hike_id': 1,
          'total_amount': 999999.99,
          'status': 'pending',
        };
        expect(service.validateOrderData(largeAmountData), isTrue);

        // Extra fields (should be allowed)
        final extraFieldsData = {
          'user_id': 'user123',
          'hike_id': 1,
          'total_amount': 49.99,
          'status': 'pending',
          'extra_field': 'should be ignored',
          'tracking_number': 'TRACK123',
        };
        expect(service.validateOrderData(extraFieldsData), isTrue);
      });

      test('validateUpdateData should handle partial updates', () {
        // Empty update (should be valid)
        expect(service.validateUpdateData({}), isTrue);

        // Single field updates
        expect(service.validateUpdateData({'status': 'shipped'}), isTrue);
        expect(service.validateUpdateData({'total_amount': 59.99}), isTrue);
        expect(
          service.validateUpdateData({'tracking_number': 'TRACK123'}),
          isTrue,
        );

        // Multiple field updates
        final multiUpdate = {
          'status': 'shipped',
          'tracking_number': 'TRACK123',
          'total_amount': 59.99,
        };
        expect(service.validateUpdateData(multiUpdate), isTrue);
      });
    });
  });
}
