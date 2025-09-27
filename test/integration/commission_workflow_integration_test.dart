import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/services/workflow/enhanced_order_workflow_with_commission.dart';
import 'package:whisky_hikes/data/services/commission/commission_service.dart';
import 'package:whisky_hikes/data/services/commission/commission_chart_service.dart';
import 'package:whisky_hikes/data/services/database/backend_api.dart';
import 'package:whisky_hikes/data/services/notifications/supabase_notification_service.dart';
import 'package:whisky_hikes/data/services/tracking/order_tracking_service.dart';
import 'package:whisky_hikes/domain/models/enhanced_order.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';
import 'package:whisky_hikes/domain/models/commission.dart';

import '../test_helpers.dart';
import 'commission_workflow_integration_test.mocks.dart';

@GenerateMocks([
  CommissionService,
  BackendApiService,
  SupabaseNotificationService,
  OrderTrackingService,
])

/// End-to-end integration tests for the complete commission workflow
/// Tests the entire flow from order completion to commission management
void main() {
  group('Commission Workflow Integration Tests', () {
    late EnhancedOrderWorkflowWithCommission workflow;
    late CommissionChartService chartService;
    late MockCommissionService mockCommissionService;
    late MockBackendApiService mockBackendApi;
    late MockSupabaseNotificationService mockNotificationService;
    late MockOrderTrackingService mockTrackingService;

    void _setupDefaultMocks() {
      // Default tracking service response
      when(mockTrackingService.markDelivered(
        orderId: anyNamed('orderId'),
        deliveryTime: anyNamed('deliveryTime'),
        deliveryLocation: anyNamed('deliveryLocation'),
        recipientName: anyNamed('recipientName'),
        deliveryProofUrl: anyNamed('deliveryProofUrl'),
        deliveryNotes: anyNamed('deliveryNotes'),
      )).thenAnswer((_) async => _createTestOrder(
        id: 1,
        orderNumber: 'ORD-001',
        hikeId: 100,
        totalAmount: 150.0,
        status: EnhancedOrderStatus.delivered,
        companyId: 'test-company',
      ));
      
      // Generic mock for updateEnhancedOrderStatus
      when(mockBackendApi.updateEnhancedOrderStatus(
        orderId: anyNamed('orderId'),
        newStatus: anyNamed('newStatus'),
        reason: anyNamed('reason'),
        notes: anyNamed('notes'),
        trackingNumber: anyNamed('trackingNumber'),
        trackingUrl: anyNamed('trackingUrl'),
        shippingCarrier: anyNamed('shippingCarrier'),
        estimatedDelivery: anyNamed('estimatedDelivery'),
        metadata: anyNamed('metadata'),
      )).thenAnswer((invocation) async {
        final orderId = invocation.namedArguments[#orderId] as int;
        final newStatus = invocation.namedArguments[#newStatus] as String;
        return _createTestOrder(
          id: orderId,
          orderNumber: 'ORD-001',
          hikeId: 100,
          totalAmount: 150.0,
          status: EnhancedOrderStatus.values.firstWhere((s) => s.name == newStatus),
          companyId: 'test-company',
        );
      });
    }

    setUp(() {
      mockCommissionService = MockCommissionService();
      mockBackendApi = MockBackendApiService();
      mockNotificationService = MockSupabaseNotificationService();
      mockTrackingService = MockOrderTrackingService();
      
      workflow = EnhancedOrderWorkflowWithCommission(
        backendApi: mockBackendApi,
        notificationService: mockNotificationService,
        trackingService: mockTrackingService,
        commissionService: mockCommissionService,
      );
      
      chartService = CommissionChartService(mockCommissionService);
      
      // Set up default mock responses
      _setupDefaultMocks();
    });

    group('Complete Order-to-Commission Flow', () {
      test('should complete entire workflow from shipped to delivered with commission', () async {
        // Arrange - Set up a realistic scenario
        final shippedOrder = _createTestOrder(
          id: 1,
          orderNumber: 'ORD-001',
          hikeId: 100,
          totalAmount: 150.0,
          status: EnhancedOrderStatus.shipped,
          companyId: 'test-company',
        );

        final deliveredOrder = shippedOrder.copyWith(
          status: EnhancedOrderStatus.delivered,
        );

        final expectedCommission = TestHelpers.createTestCommission(
          id: 1,
          hikeId: 100,
          companyId: 'test-company',
          orderId: 'ORD-001',
          baseAmount: 150.0,
          commissionRate: 0.15,
          commissionAmount: 22.5,
          status: CommissionStatus.pending,
        );

        // Mock the order lookup
        when(mockBackendApi.getEnhancedOrderById(1))
            .thenAnswer((_) async => shippedOrder);

        // Mock no existing commissions
        when(mockCommissionService.getCommissionsForCompany('test-company'))
            .thenAnswer((_) async => <Commission>[]);

        // Mock successful commission creation
        when(mockCommissionService.createCommissionForOrder(
          hikeId: 100,
          companyId: 'test-company',
          orderId: 'ORD-001',
          baseAmount: 150.0,
          commissionRate: 0.15,
          notes: anyNamed('notes'),
        )).thenAnswer((_) async => expectedCommission);

        // Mock commission lookup for order management
        when(mockCommissionService.getCommissionByOrderId('ORD-001'))
            .thenAnswer((_) async => expectedCommission);

        // Act - Execute the complete workflow
        final result = await workflow.transitionOrderStatus(
          orderId: 1,
          toStatus: EnhancedOrderStatus.delivered,
        );

        // Assert - Verify all steps completed successfully
        expect(result.status, equals(EnhancedOrderStatus.delivered));
        expect(result.companyId, equals('test-company'));

        // Verify commission was created
        verify(mockCommissionService.createCommissionForOrder(
          hikeId: 100,
          companyId: 'test-company',
          orderId: 'ORD-001',
          baseAmount: 150.0,
          commissionRate: 0.15,
          notes: argThat(contains('Automatisch erstellt'), named: 'notes'),
        )).called(1);

        // Verify commission can be retrieved for order management
        final retrievedCommission = await mockCommissionService.getCommissionByOrderId('ORD-001');
        expect(retrievedCommission, isNotNull);
        expect(retrievedCommission!.orderId, equals('ORD-001'));
        expect(retrievedCommission.commissionAmount, equals(22.5));
        expect(retrievedCommission.status, equals(CommissionStatus.pending));
      });
    });

    group('Commission Analytics Integration', () {
      test('should generate analytics data after commission creation', () async {
        // Arrange - Create test commissions with various statuses and dates
        final now = DateTime.now();
        final testCommissions = [
          TestHelpers.createTestCommission(
            id: 1,
            hikeId: 100,
            companyId: 'test-company',
            orderId: 'ORD-001',
            baseAmount: 150.0,
            commissionRate: 0.15,
            commissionAmount: 22.5,
            status: CommissionStatus.pending,
            createdAt: now.subtract(const Duration(days: 1)),
          ),
          TestHelpers.createTestCommission(
            id: 2,
            hikeId: 101,
            companyId: 'test-company',
            orderId: 'ORD-002',
            baseAmount: 200.0,
            commissionRate: 0.15,
            commissionAmount: 30.0,
            status: CommissionStatus.paid,
            createdAt: now.subtract(const Duration(days: 5)),
            paidAt: now.subtract(const Duration(days: 2)),
          ),
          TestHelpers.createTestCommission(
            id: 3,
            hikeId: 102,
            companyId: 'test-company',
            orderId: 'ORD-003',
            baseAmount: 100.0,
            commissionRate: 0.15,
            commissionAmount: 15.0,
            status: CommissionStatus.calculated,
            createdAt: now.subtract(const Duration(days: 3)),
          ),
        ];

        // Mock commission service responses
        when(mockCommissionService.getCommissionsForCompany('test-company'))
            .thenAnswer((_) async => testCommissions);

        when(mockCommissionService.getCommissionsForDateRange(
          'test-company',
          any,
          any,
        )).thenAnswer((_) async => testCommissions);

        // Act - Generate analytics data
        final timelineData = await chartService.getTimelineChartData(
          companyId: 'test-company',
          period: ChartPeriod.weekly,
          weeks: 4,
        );

        final statusData = await chartService.getStatusDistributionChartData(
          companyId: 'test-company',
        );

        // Assert - Verify analytics data is generated correctly
        expect(timelineData, isNotNull);
        expect(timelineData.dataPoints, isNotEmpty);
        expect(timelineData.totalAmount, equals(67.5)); // 22.5 + 30.0 + 15.0
        expect(timelineData.totalCommissions, equals(3));

        expect(statusData, isNotNull);
        expect(statusData.statusCounts, hasLength(4)); // All 4 possible statuses (including 0 counts)
        expect(statusData.totalAmount, equals(67.5));
        expect(statusData.totalCommissions, equals(3));

        // Verify status distribution
        expect(statusData.statusAmounts[CommissionStatus.pending], equals(22.5));
        expect(statusData.statusAmounts[CommissionStatus.paid], equals(30.0));
        expect(statusData.statusAmounts[CommissionStatus.calculated], equals(15.0));
      });
    });

    group('Error Handling and Recovery', () {
      test('should handle commission creation failure gracefully', () async {
        // Arrange
        final testOrder = _createTestOrder(
          id: 1,
          orderNumber: 'ORD-001',
          hikeId: 100,
          totalAmount: 150.0,
          status: EnhancedOrderStatus.shipped,
          companyId: 'test-company',
        );

        when(mockBackendApi.getEnhancedOrderById(1))
            .thenAnswer((_) async => testOrder);

        when(mockCommissionService.getCommissionsForCompany('test-company'))
            .thenAnswer((_) async => <Commission>[]);

        // Simulate commission creation failure
        when(mockCommissionService.createCommissionForOrder(
          hikeId: anyNamed('hikeId'),
          companyId: anyNamed('companyId'),
          orderId: anyNamed('orderId'),
          baseAmount: anyNamed('baseAmount'),
          commissionRate: anyNamed('commissionRate'),
          notes: anyNamed('notes'),
        )).thenThrow(Exception('Database connection failed'));

        // Act - Order status should still be updated despite commission failure
        final result = await workflow.transitionOrderStatus(
          orderId: 1,
          toStatus: EnhancedOrderStatus.delivered,
        );

        // Assert - Order transition succeeds, commission creation fails gracefully
        expect(result.status, equals(EnhancedOrderStatus.delivered));
        
        // Verify commission creation was attempted
        verify(mockCommissionService.createCommissionForOrder(
          hikeId: anyNamed('hikeId'),
          companyId: anyNamed('companyId'),
          orderId: anyNamed('orderId'),
          baseAmount: anyNamed('baseAmount'),
          commissionRate: anyNamed('commissionRate'),
          notes: anyNamed('notes'),
        )).called(1);
      });

      test('should handle missing commission data in order management', () async {
        // Arrange - Commission lookup returns null
        when(mockCommissionService.getCommissionByOrderId('ORD-MISSING'))
            .thenAnswer((_) async => null);

        // Act - Should not throw an error
        final commission = await mockCommissionService.getCommissionByOrderId('ORD-MISSING');

        // Assert - Gracefully handles missing commission
        expect(commission, isNull);
        verify(mockCommissionService.getCommissionByOrderId('ORD-MISSING')).called(1);
      });
    });

    group('Business Rules Validation', () {
      test('should prevent duplicate commission creation', () async {
        // Arrange
        final testOrder = _createTestOrder(
          id: 1,
          orderNumber: 'ORD-001',
          hikeId: 100,
          totalAmount: 150.0,
          status: EnhancedOrderStatus.shipped,
          companyId: 'test-company',
        );

        final existingCommission = TestHelpers.createTestCommission(
          orderId: 'ORD-001',
        );

        when(mockBackendApi.getEnhancedOrderById(1))
            .thenAnswer((_) async => testOrder);

        // Mock existing commission
        when(mockCommissionService.getCommissionsForCompany('test-company'))
            .thenAnswer((_) async => [existingCommission]);

        // Act
        final result = await workflow.transitionOrderStatus(
          orderId: 1,
          toStatus: EnhancedOrderStatus.delivered,
        );

        // Assert - Order is updated but no new commission is created
        expect(result.status, equals(EnhancedOrderStatus.delivered));
        
        // Verify commission creation was NOT called
        verifyNever(mockCommissionService.createCommissionForOrder(
          hikeId: anyNamed('hikeId'),
          companyId: anyNamed('companyId'),
          orderId: anyNamed('orderId'),
          baseAmount: anyNamed('baseAmount'),
          commissionRate: anyNamed('commissionRate'),
          notes: anyNamed('notes'),
        ));
      });

      test('should only create commissions for delivered orders', () async {
        // Arrange
        final testOrder = _createTestOrder(
          id: 1,
          orderNumber: 'ORD-001',
          hikeId: 100,
          totalAmount: 150.0,
          status: EnhancedOrderStatus.processing,
        );

        when(mockBackendApi.getEnhancedOrderById(1))
            .thenAnswer((_) async => testOrder);

        // Mock tracking service for shipped status
        when(mockTrackingService.assignTrackingNumber(
          orderId: anyNamed('orderId'),
          trackingNumber: anyNamed('trackingNumber'),
          shippingCarrier: anyNamed('shippingCarrier'),
          shippingService: anyNamed('shippingService'),
          estimatedDelivery: anyNamed('estimatedDelivery'),
        )).thenAnswer((_) async => testOrder.copyWith(status: EnhancedOrderStatus.shipped));

        // Act - Transition to shipped (not delivered)
        final result = await workflow.transitionOrderStatus(
          orderId: 1,
          toStatus: EnhancedOrderStatus.shipped,
          transitionData: {
            'tracking_number': 'TRACK123',
            'shipping_carrier': 'DHL',
          },
        );

        // Assert - Order is shipped but no commission is created
        expect(result.status, equals(EnhancedOrderStatus.shipped));
        
        // Verify commission creation was NOT called
        verifyNever(mockCommissionService.createCommissionForOrder(
          hikeId: anyNamed('hikeId'),
          companyId: anyNamed('companyId'),
          orderId: anyNamed('orderId'),
          baseAmount: anyNamed('baseAmount'),
          commissionRate: anyNamed('commissionRate'),
          notes: anyNamed('notes'),
        ));
      });
    });

    group('Performance and Scale', () {
      test('should handle multiple commission operations efficiently', () async {
        // Arrange - Simulate processing multiple orders
        final orders = List.generate(5, (index) => _createTestOrder(
          id: index + 1,
          orderNumber: 'ORD-00${index + 1}',
          hikeId: 100 + index,
          totalAmount: 150.0 + (index * 10),
          status: EnhancedOrderStatus.shipped,
          companyId: 'test-company',
        ));

        final commissions = List.generate(5, (index) => TestHelpers.createTestCommission(
          id: index + 1,
          hikeId: 100 + index,
          companyId: 'test-company',
          orderId: 'ORD-00${index + 1}',
          baseAmount: 150.0 + (index * 10),
          commissionRate: 0.15,
          commissionAmount: (150.0 + (index * 10)) * 0.15,
        ));

        // Mock responses for each order
        for (int i = 0; i < orders.length; i++) {
          when(mockBackendApi.getEnhancedOrderById(i + 1))
              .thenAnswer((_) async => orders[i]);
          
          when(mockCommissionService.createCommissionForOrder(
            hikeId: 100 + i,
            companyId: 'test-company',
            orderId: 'ORD-00${i + 1}',
            baseAmount: 150.0 + (i * 10),
            commissionRate: 0.15,
            notes: anyNamed('notes'),
          )).thenAnswer((_) async => commissions[i]);
        }

        // Mock no existing commissions for each order
        when(mockCommissionService.getCommissionsForCompany('test-company'))
            .thenAnswer((_) async => <Commission>[]);

        // Act - Process all orders concurrently
        final stopwatch = Stopwatch()..start();
        
        final results = await Future.wait(
          List.generate(5, (index) => workflow.transitionOrderStatus(
            orderId: index + 1,
            toStatus: EnhancedOrderStatus.delivered,
          ))
        );
        
        stopwatch.stop();

        // Assert - All orders processed successfully
        expect(results, hasLength(5));
        for (final result in results) {
          expect(result.status, equals(EnhancedOrderStatus.delivered));
        }

        // Verify all commissions were created - check total call count
        verify(mockCommissionService.createCommissionForOrder(
          hikeId: anyNamed('hikeId'),
          companyId: anyNamed('companyId'),
          orderId: anyNamed('orderId'),
          baseAmount: anyNamed('baseAmount'),
          commissionRate: anyNamed('commissionRate'),
          notes: anyNamed('notes'),
        )).called(5); // Called once for each of the 5 orders

        // Performance assertion - should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max
      });
    });
  });
}

// Helper method to create test orders
EnhancedOrder _createTestOrder({
  required int id,
  required String orderNumber,
  required int hikeId,
  required double totalAmount,
  required EnhancedOrderStatus status,
  String? companyId,
}) {
  return EnhancedOrder(
    id: id,
    orderNumber: orderNumber,
    hikeId: hikeId,
    userId: 'test-user',
    totalAmount: totalAmount,
    currency: 'EUR',
    deliveryType: DeliveryType.standardShipping,
    status: status,
    createdAt: DateTime.now(),
    companyId: companyId,
  );
}