import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/web/admin/order_management/order_management_page.dart';
import 'package:whisky_hikes/UI/web/admin/order_management/widgets/order_filter_widget.dart';
import 'package:whisky_hikes/UI/web/admin/order_management/widgets/order_list_widget.dart';
import 'package:whisky_hikes/UI/web/admin/order_management/widgets/order_statistics_widget.dart';
import 'package:whisky_hikes/UI/web/admin/order_management/widgets/order_status_chip.dart';
import 'package:whisky_hikes/data/providers/order_management_provider.dart';
import '../../../../data/test_helpers.dart';
import '../../../../data/providers/order_management_provider_test.mocks.dart';

void main() {
  late MockOrderManagementService mockOrderManagementService;
  late OrderManagementProvider orderManagementProvider;

  setUp(() {
    mockOrderManagementService = MockOrderManagementService();
    orderManagementProvider = OrderManagementProvider(
      orderManagementService: mockOrderManagementService,
    );

    // Setup default mock responses
    when(mockOrderManagementService.getAllOrdersForAdmin()).thenAnswer(
      (_) async => [
        TestHelpers.createTestBasicOrderJson(id: 1, userId: 'user1'),
        TestHelpers.createTestBasicOrderJson(
          id: 2,
          userId: 'user2',
          status: 'delivered',
        ),
      ],
    );

    when(mockOrderManagementService.getOrderStatistics()).thenAnswer(
      (_) async => {
        'total_orders': 2,
        'total_revenue': 199.98,
        'average_order_value': 99.99,
        'orders_today': 1,
        'status_distribution': {'pending': 1, 'delivered': 1},
      },
    );

    when(mockOrderManagementService.getValidStatuses()).thenReturn([
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
      'refunded',
    ]);
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: ChangeNotifierProvider<OrderManagementProvider>.value(
        value: orderManagementProvider,
        child: Material(child: child),
      ),
    );
  }

  group('OrderStatusChip Widget Tests', () {
    testWidgets('should display correct status and color for pending order', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const OrderStatusChip(status: 'pending')),
      );

      expect(find.text('Ausstehend'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display correct status for delivered order', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const OrderStatusChip(status: 'delivered')),
      );

      expect(find.text('Zugestellt'), findsOneWidget);
    });

    testWidgets('should display unknown status for invalid status', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const OrderStatusChip(status: 'invalid_status')),
      );

      expect(find.text('invalid_status'), findsOneWidget);
    });

    testWidgets('should be clickable when isClickable is true', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          OrderStatusChip(
            status: 'pending',
            isClickable: true,
            onTap: () => wasTapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(wasTapped, true);
    });
  });

  group('OrderFilterWidget Tests', () {
    testWidgets('should render filter components', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const Scaffold(body: OrderFilterWidget())),
      );

      expect(find.text('Filter'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Zeitraum'), findsOneWidget);
      expect(find.text('Betrag'), findsOneWidget);
      expect(find.text('Suche'), findsOneWidget);
    });

    testWidgets('should display status dropdown', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const Scaffold(body: OrderFilterWidget())),
      );

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Alle Status'), findsOneWidget);
    });

    testWidgets('should display amount filter text fields', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const Scaffold(body: OrderFilterWidget())),
      );

      expect(find.byType(TextFormField), findsNWidgets(3)); // Min, Max, Search
      expect(find.text('Min €'), findsOneWidget);
      expect(find.text('Max €'), findsOneWidget);
    });

    testWidgets('should display search field', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const Scaffold(body: OrderFilterWidget())),
      );

      expect(find.text('Order ID, User ID...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });

  group('OrderStatisticsWidget Tests', () {
    testWidgets('should display loading indicator when loading', (
      tester,
    ) async {
      orderManagementProvider.setLoading(true);

      await tester.pumpWidget(
        createTestWidget(const Scaffold(body: OrderStatisticsWidget())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display statistics when loaded', (tester) async {
      // Load some test statistics
      await orderManagementProvider.loadOrderStatistics();
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        createTestWidget(const Scaffold(body: OrderStatisticsWidget())),
      );

      expect(find.text('Statistiken'), findsOneWidget);
      expect(find.text('Gesamtumsatz'), findsOneWidget);
      expect(find.text('Bestellungen'), findsOneWidget);
      expect(find.text('Ø Bestellwert'), findsOneWidget);
      expect(find.text('Heute'), findsOneWidget);
    });

    testWidgets('should display empty message when no statistics', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const Scaffold(body: OrderStatisticsWidget())),
      );

      expect(find.text('Keine Statistiken verfügbar'), findsOneWidget);
    });

    testWidgets('should display time period selector', (tester) async {
      // Load some test statistics first
      await orderManagementProvider.loadOrderStatistics();
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        createTestWidget(const Scaffold(body: OrderStatisticsWidget())),
      );

      expect(find.byType(SegmentedButton<String>), findsOneWidget);
      expect(
        find.text('Heute'),
        findsNWidgets(2),
      ); // One in statistics card, one in selector
      expect(find.text('Woche'), findsOneWidget);
      expect(find.text('Monat'), findsOneWidget);
    });
  });

  group('OrderListWidget Tests', () {
    testWidgets('should display loading indicator when loading', (
      tester,
    ) async {
      orderManagementProvider.setLoading(true);

      await tester.pumpWidget(
        createTestWidget(const Scaffold(body: OrderListWidget())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message when error occurs', (
      tester,
    ) async {
      orderManagementProvider.setError('Test error message');

      await tester.pumpWidget(
        createTestWidget(const Scaffold(body: OrderListWidget())),
      );

      expect(find.text('Fehler beim Laden der Bestellungen'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('Erneut versuchen'), findsOneWidget);
    });

    testWidgets('should display empty state when no orders', (tester) async {
      when(
        mockOrderManagementService.getAllOrdersForAdmin(),
      ).thenAnswer((_) async => []);

      await orderManagementProvider.loadOrders();
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        createTestWidget(const Scaffold(body: OrderListWidget())),
      );

      expect(find.text('Keine Bestellungen gefunden'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('should display orders in responsive layout', (tester) async {
      await orderManagementProvider.loadOrders();
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        createTestWidget(const Scaffold(body: OrderListWidget())),
      );

      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('OrderManagementPage Integration Tests', () {
    testWidgets('should render all components together', (tester) async {
      // Set a larger screen size for desktop layout
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await orderManagementProvider.loadOrders();
      await orderManagementProvider.loadOrderStatistics();
      await tester.pumpAndSettle();

      await tester.pumpWidget(createTestWidget(const OrderManagementPage()));

      expect(find.text('Order Management'), findsOneWidget);
      expect(find.byType(OrderStatisticsWidget), findsOneWidget);
      expect(find.byType(OrderFilterWidget), findsOneWidget);
      expect(find.byType(OrderListWidget), findsOneWidget);

      // Reset screen size
      tester.view.resetPhysicalSize();
    });

    testWidgets('should display refresh button', (tester) async {
      await tester.pumpWidget(createTestWidget(const OrderManagementPage()));

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should handle refresh button tap', (tester) async {
      await tester.pumpWidget(createTestWidget(const OrderManagementPage()));

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Verify that loadOrders was called
      verify(
        mockOrderManagementService.getAllOrdersForAdmin(),
      ).called(greaterThan(1));
    });
  });
}
