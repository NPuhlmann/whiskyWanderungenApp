import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/UI/orders/widgets/order_status_timeline.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';
import 'package:whisky_hikes/domain/models/enhanced_order.dart';

void main() {
  group('OrderStatusTimeline', () {
    late BasicOrder basicOrder;
    late EnhancedOrder enhancedOrder;

    setUp(() {
      basicOrder = BasicOrder(
        id: 1,
        orderNumber: 'WH2024-12345',
        hikeId: 1,
        userId: 'test-user-id',
        totalAmount: 49.99,
        deliveryType: DeliveryType.shipping,
        status: OrderStatus.confirmed,
        createdAt: DateTime.now(),
      );

      enhancedOrder = EnhancedOrder(
        id: 1,
        orderNumber: 'WH2024-12345',
        hikeId: 1,
        userId: 'test-user-id',
        totalAmount: 49.99,
        baseAmount: 44.99,
        shippingCost: 5.0,
        deliveryType: enhanced.DeliveryType.shipping,
        status: EnhancedOrderStatus.confirmed,
        createdAt: DateTime.now(),
        statusHistory: [],
      );
    });

    group('Basic Order Timeline', () {
      testWidgets('should display timeline for basic order', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.basic(order: basicOrder),
            ),
          ),
        );

        expect(find.text('Bestellstatus'), findsOneWidget);
        expect(find.byIcon(Icons.timeline), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('should show correct status for pending order', (tester) async {
        final pendingOrder = basicOrder.copyWith(status: OrderStatus.pending);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.basic(order: pendingOrder),
            ),
          ),
        );

        expect(find.text('Bestellung eingegangen'), findsOneWidget);
        expect(find.text('Deine Bestellung wurde erfolgreich aufgegeben'), findsOneWidget);
      });

      testWidgets('should show correct status for confirmed order', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.basic(order: basicOrder),
            ),
          ),
        );

        expect(find.text('Bestellung bestätigt'), findsOneWidget);
        expect(find.text('Zahlung bestätigt, Bestellung wird vorbereitet'), findsOneWidget);
      });

      testWidgets('should show correct status for shipped order', (tester) async {
        final shippedOrder = basicOrder.copyWith(status: OrderStatus.shipped);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.basic(order: shippedOrder),
            ),
          ),
        );

        expect(find.text('Versendet'), findsOneWidget);
        expect(find.text('Dein Paket ist auf dem Weg'), findsOneWidget);
      });

      testWidgets('should show correct status for delivered order', (tester) async {
        final deliveredOrder = basicOrder.copyWith(status: OrderStatus.delivered);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.basic(order: deliveredOrder),
            ),
          ),
        );

        expect(find.text('Zugestellt'), findsOneWidget);
        expect(find.text('Dein Paket wurde erfolgreich zugestellt'), findsOneWidget);
      });

      testWidgets('should show correct status for cancelled order', (tester) async {
        final cancelledOrder = basicOrder.copyWith(status: OrderStatus.cancelled);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.basic(order: cancelledOrder),
            ),
          ),
        );

        expect(find.text('Storniert'), findsOneWidget);
        expect(find.text('Bestellung wurde storniert'), findsOneWidget);
      });
    });

    group('Enhanced Order Timeline', () {
      testWidgets('should display timeline for enhanced order', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.enhanced(order: enhancedOrder),
            ),
          ),
        );

        expect(find.text('Bestellstatus'), findsOneWidget);
        expect(find.byIcon(Icons.timeline), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('should show enhanced status descriptions', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.enhanced(order: enhancedOrder),
            ),
          ),
        );

        expect(find.text('Bestellung bestätigt'), findsOneWidget);
        expect(find.text('Zahlung bestätigt, Bestellung wird vorbereitet'), findsOneWidget);
      });

      testWidgets('should show payment pending status', (tester) async {
        final paymentPendingOrder = enhancedOrder.copyWith(
          status: EnhancedOrderStatus.paymentPending,
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.enhanced(order: paymentPendingOrder),
            ),
          ),
        );

        expect(find.text('Zahlung ausstehend'), findsOneWidget);
        expect(find.text('Warte auf Zahlungsbestätigung'), findsOneWidget);
      });

      testWidgets('should show out for delivery status', (tester) async {
        final outForDeliveryOrder = enhancedOrder.copyWith(
          status: EnhancedOrderStatus.outForDelivery,
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.enhanced(order: outForDeliveryOrder),
            ),
          ),
        );

        expect(find.text('Zustellung unterwegs'), findsOneWidget);
        expect(find.text('Zustellung erfolgt heute'), findsOneWidget);
      });

      testWidgets('should show refunded status', (tester) async {
        final refundedOrder = enhancedOrder.copyWith(
          status: EnhancedOrderStatus.refunded,
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.enhanced(order: refundedOrder),
            ),
          ),
        );

        expect(find.text('Erstattet'), findsOneWidget);
        expect(find.text('Betrag wurde erstattet'), findsOneWidget);
      });

      testWidgets('should show failed status', (tester) async {
        final failedOrder = enhancedOrder.copyWith(
          status: EnhancedOrderStatus.failed,
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.enhanced(order: failedOrder),
            ),
          ),
        );

        expect(find.text('Fehlgeschlagen'), findsOneWidget);
        expect(find.text('Bestellung konnte nicht verarbeitet werden'), findsOneWidget);
      });
    });

    group('Timeline Visual Elements', () {
      testWidgets('should display timeline visual elements correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.basic(order: basicOrder),
            ),
          ),
        );

        // Check for timeline circles (status indicators)
        expect(find.byType(Container), findsWidgets);
        
        // Check for check icons (completed status)
        expect(find.byIcon(Icons.check), findsWidgets);
      });

      testWidgets('should handle unknown order type gracefully', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline(order: 'invalid_order_type'),
            ),
          ),
        );

        expect(find.text('Unbekannter Bestelltyp'), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      });
    });

    group('Status Progression Logic', () {
      testWidgets('should show completed statuses correctly for shipped order', (tester) async {
        final shippedOrder = basicOrder.copyWith(status: OrderStatus.shipped);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.basic(order: shippedOrder),
            ),
          ),
        );

        // Pending, confirmed, processing should be completed
        // Shipped should be current
        // Delivered should not be completed
        expect(find.byIcon(Icons.check), findsWidgets);
      });

      testWidgets('should show current status correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderStatusTimeline.basic(order: basicOrder),
            ),
          ),
        );

        // Check for schedule icon (current status)
        expect(find.byIcon(Icons.schedule), findsWidgets);
      });
    });
  });
}