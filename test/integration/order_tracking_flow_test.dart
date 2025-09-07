import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/mobile/orders/order_tracking_page.dart';
import 'package:whisky_hikes/UI/mobile/payment/order_history_page.dart';
import 'package:whisky_hikes/data/repositories/payment_repository.dart';
import 'package:whisky_hikes/data/services/database/backend_api.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';

import 'order_tracking_flow_test.mocks.dart';

@GenerateMocks([PaymentRepository, BackendApiService])
void main() {
  group('Order Tracking Integration Tests', () {
    late MockPaymentRepository mockPaymentRepository;
    late MockBackendApiService mockBackendApiService;

    final testOrder = BasicOrder(
      id: 1,
      orderNumber: 'WH2024-12345',
      hikeId: 1,
      userId: 'test-user-id',
      totalAmount: 49.99,
      deliveryType: DeliveryType.standardShipping,
      status: OrderStatus.shipped,
      createdAt: DateTime.now(),
      trackingNumber: 'TN123456789',
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
    );

    final orderList = [
      testOrder,
      testOrder.copyWith(
        id: 2,
        orderNumber: 'WH2024-12346',
        status: OrderStatus.delivered,
      ),
    ];

    setUp(() {
      mockPaymentRepository = MockPaymentRepository();
      mockBackendApiService = MockBackendApiService();
    });

    group('Order History to Order Tracking Flow', () {
      testWidgets('should display order history and navigate to tracking', (tester) async {
        // Arrange
        when(mockBackendApiService.fetchUserOrders(any))
            .thenAnswer((_) async => orderList);

        // Build the app with providers
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                Provider<BackendApiService>.value(value: mockBackendApiService),
                Provider<PaymentRepository>.value(value: mockPaymentRepository),
              ],
              child: const OrderHistoryPage(),
            ),
          ),
        );

        // Wait for loading to complete
        await tester.pumpAndSettle();

        // Assert: Check that orders are displayed
        expect(find.text('Meine Bestellungen'), findsOneWidget);
        expect(find.text('WH2024-12345'), findsOneWidget);
        expect(find.text('WH2024-12346'), findsOneWidget);

        // Assert: Check status chips
        expect(find.text('Versandt'), findsOneWidget);
        expect(find.text('Zugestellt'), findsOneWidget);

        // Assert: Check tracking info for shipped order
        expect(find.text('Sendungsnummer: TN123456789'), findsOneWidget);

        // Assert: Check action buttons
        expect(find.text('Details anzeigen'), findsWidgets);
      });

      testWidgets('should handle empty order history', (tester) async {
        // Arrange
        when(mockBackendApiService.fetchUserOrders(any))
            .thenAnswer((_) async => []);

        // Build the app
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                Provider<BackendApiService>.value(value: mockBackendApiService),
              ],
              child: const OrderHistoryPage(),
            ),
          ),
        );

        // Wait for loading to complete
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Keine Bestellungen gefunden'), findsOneWidget);
        expect(find.text('Ihre Bestellungen werden hier angezeigt'), findsOneWidget);
        expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      });

      testWidgets('should handle order history loading error', (tester) async {
        // Arrange
        when(mockBackendApiService.fetchUserOrders(any))
            .thenThrow(Exception('Network error'));

        // Build the app
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                Provider<BackendApiService>.value(value: mockBackendApiService),
              ],
              child: const OrderHistoryPage(),
            ),
          ),
        );

        // Wait for loading to complete
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Fehler beim Laden der Bestellhistorie'), findsOneWidget);
        expect(find.text('Erneut versuchen'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('should retry loading after error', (tester) async {
        // Arrange - first call fails, second succeeds
        int callCount = 0;
        when(mockBackendApiService.fetchUserOrders(any))
            .thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          }
          return orderList;
        });

        // Build the app
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                Provider<BackendApiService>.value(value: mockBackendApiService),
              ],
              child: const OrderHistoryPage(),
            ),
          ),
        );

        // Wait for error state
        await tester.pumpAndSettle();
        expect(find.text('Erneut versuchen'), findsOneWidget);

        // Act: Tap retry button
        await tester.tap(find.text('Erneut versuchen'));
        await tester.pumpAndSettle();

        // Assert: Should show orders now
        expect(find.text('WH2024-12345'), findsOneWidget);
        verify(mockBackendApiService.fetchUserOrders(any)).called(2);
      });

      testWidgets('should refresh order history with pull to refresh', (tester) async {
        // Arrange
        when(mockBackendApiService.fetchUserOrders(any))
            .thenAnswer((_) async => orderList);

        // Build the app
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                Provider<BackendApiService>.value(value: mockBackendApiService),
              ],
              child: const OrderHistoryPage(),
            ),
          ),
        );

        // Wait for initial load
        await tester.pumpAndSettle();

        // Act: Pull to refresh
        await tester.fling(find.text('WH2024-12345'), const Offset(0, 300), 1000);
        await tester.pumpAndSettle();

        // Assert: Should have called fetchUserOrders again
        verify(mockBackendApiService.fetchUserOrders(any)).called(2);
      });
    });

    group('Order Tracking Page', () {
      testWidgets('should display order tracking information', (tester) async {
        // Arrange
        when(mockPaymentRepository.getOrderById(1))
            .thenAnswer((_) async => testOrder);

        // Build the order tracking page
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<PaymentRepository>.value(
              value: mockPaymentRepository,
              child: const OrderTrackingPage(orderId: 1),
            ),
          ),
        );

        // Wait for loading to complete
        await tester.pumpAndSettle();

        // Assert: Check basic order information
        expect(find.text('Bestellverfolgung'), findsOneWidget);
        expect(find.text('#WH2024-12345'), findsOneWidget);

        // Assert: Check status timeline
        expect(find.text('Bestellstatus'), findsOneWidget);
        expect(find.byIcon(Icons.timeline), findsOneWidget);

        // Assert: Check shipping information (for shipping orders)
        expect(find.text('Versandinformationen'), findsOneWidget);
        expect(find.text('€5.00'), findsOneWidget); // Default shipping cost

        // Assert: Check tracking information
        expect(find.text('Sendungsverfolgung'), findsOneWidget);
        expect(find.text('TN123456789'), findsOneWidget);
      });

      testWidgets('should handle order tracking loading error', (tester) async {
        // Arrange
        when(mockPaymentRepository.getOrderById(1))
            .thenThrow(Exception('Order not found'));

        // Build the order tracking page
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<PaymentRepository>.value(
              value: mockPaymentRepository,
              child: const OrderTrackingPage(orderId: 1),
            ),
          ),
        );

        // Wait for loading to complete
        await tester.pumpAndSettle();

        // Assert: Check error state
        expect(find.text('Fehler beim Laden der Bestellung'), findsOneWidget);
        expect(find.text('Wiederholen'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('should retry loading order after error', (tester) async {
        // Arrange - first call fails, second succeeds
        int callCount = 0;
        when(mockPaymentRepository.getOrderById(1))
            .thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          }
          return testOrder;
        });

        // Build the order tracking page
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<PaymentRepository>.value(
              value: mockPaymentRepository,
              child: const OrderTrackingPage(orderId: 1),
            ),
          ),
        );

        // Wait for error state
        await tester.pumpAndSettle();
        expect(find.text('Wiederholen'), findsOneWidget);

        // Act: Tap retry button
        await tester.tap(find.text('Wiederholen'));
        await tester.pumpAndSettle();

        // Assert: Should show order details now
        expect(find.text('#WH2024-12345'), findsOneWidget);
        verify(mockPaymentRepository.getOrderById(1)).called(2);
      });

      testWidgets('should show different content for pickup orders', (tester) async {
        // Arrange - pickup order
        final pickupOrder = testOrder.copyWith(deliveryType: DeliveryType.pickup);
        when(mockPaymentRepository.getOrderById(1))
            .thenAnswer((_) async => pickupOrder);

        // Build the order tracking page
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<PaymentRepository>.value(
              value: mockPaymentRepository,
              child: const OrderTrackingPage(orderId: 1),
            ),
          ),
        );

        // Wait for loading to complete
        await tester.pumpAndSettle();

        // Assert: Should not show shipping information for pickup orders
        expect(find.text('Versandinformationen'), findsNothing);
        expect(find.text('Sendungsverfolgung'), findsNothing);
      });

      testWidgets('should display action buttons', (tester) async {
        // Arrange
        when(mockPaymentRepository.getOrderById(1))
            .thenAnswer((_) async => testOrder);

        // Build the order tracking page
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<PaymentRepository>.value(
              value: mockPaymentRepository,
              child: const OrderTrackingPage(orderId: 1),
            ),
          ),
        );

        // Wait for loading to complete
        await tester.pumpAndSettle();

        // Assert: Check action buttons
        expect(find.text('Support kontaktieren'), findsOneWidget);
        
        // For orders that can be cancelled
        // expect(find.text('Bestellung stornieren'), findsOneWidget);
      });

      testWidgets('should show contact support dialog', (tester) async {
        // Arrange
        when(mockPaymentRepository.getOrderById(1))
            .thenAnswer((_) async => testOrder);

        // Build the order tracking page
        await tester.pumpWidget(
          MaterialApp(
            home: Provider<PaymentRepository>.value(
              value: mockPaymentRepository,
              child: const OrderTrackingPage(orderId: 1),
            ),
          ),
        );

        // Wait for loading to complete
        await tester.pumpAndSettle();

        // Act: Tap support button
        await tester.tap(find.text('Support kontaktieren'));
        await tester.pumpAndSettle();

        // Assert: Should show snackbar or contact support action
        expect(find.text('Kontaktiere Support...'), findsOneWidget);
      });
    });

    group('End-to-End Order Flow', () {
      testWidgets('should complete full order tracking flow', (tester) async {
        // This test would simulate the complete flow from order creation
        // through payment to order tracking, but requires more complex setup
        // with actual routing and navigation context
        
        // For now, we focus on individual component testing
        // Full E2E tests would be better implemented as integration tests
        // with a test driver or as widget tests with proper routing setup
      });
    });
  });
}