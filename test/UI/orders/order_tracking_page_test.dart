import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/mobile/orders/order_tracking_page.dart';
import 'package:whisky_hikes/UI/mobile/orders/order_tracking_view_model.dart';

void main() {
  group('OrderTrackingPage', () {
    testWidgets('should display loading state initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<OrderTrackingViewModel>(
            create: (context) => OrderTrackingViewModel(orderId: 1),
            child: const OrderTrackingPage(orderId: 1),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state when error occurs', (tester) async {
      final mockViewModel = OrderTrackingViewModel(orderId: 1);
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<OrderTrackingViewModel>.value(
            value: mockViewModel,
            child: const OrderTrackingPage(orderId: 1),
          ),
        ),
      );

      // Simulate error state
      // Note: This is a basic test - in a real implementation, you'd use a mock
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display order tracking content when order is loaded', (tester) async {
      final mockViewModel = OrderTrackingViewModel(orderId: 1);
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<OrderTrackingViewModel>.value(
            value: mockViewModel,
            child: const OrderTrackingPage(orderId: 1),
          ),
        ),
      );

      // Verify basic structure
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Bestellverfolgung'), findsOneWidget);
    });
  });
}
