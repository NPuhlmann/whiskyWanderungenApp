import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/web/admin/dashboard/dashboard_overview_page.dart';
import 'package:whisky_hikes/data/providers/dashboard_provider.dart';

@GenerateMocks([DashboardProvider])
import 'dashboard_overview_page_test.mocks.dart';

void main() {
  group('DashboardOverviewPage Widget Tests', () {
    late MockDashboardProvider mockProvider;

    setUp(() {
      mockProvider = MockDashboardProvider();

      // Default mock setup
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn(null);
      when(mockProvider.hasRevenueData).thenReturn(true);
      when(mockProvider.hasOrderData).thenReturn(true);
      when(mockProvider.hasRecentOrders).thenReturn(true);
      when(mockProvider.hasPopularRoutes).thenReturn(true);
      when(mockProvider.dailyRevenue).thenReturn(150.0);
      when(mockProvider.weeklyRevenue).thenReturn(800.0);
      when(mockProvider.monthlyRevenue).thenReturn(3500.0);
      when(mockProvider.formattedDailyRevenue).thenReturn('150,00 €');
      when(mockProvider.formattedWeeklyRevenue).thenReturn('800,00 €');
      when(mockProvider.formattedMonthlyRevenue).thenReturn('3.500,00 €');
      when(mockProvider.totalActiveOrders).thenReturn(15);
      when(mockProvider.pendingOrders).thenReturn(5);
      when(mockProvider.processingOrders).thenReturn(7);
      when(mockProvider.shippedOrders).thenReturn(3);
      when(mockProvider.soldRoutesToday).thenReturn(2);
      when(mockProvider.soldRoutesThisWeek).thenReturn(12);
      when(mockProvider.soldRoutesThisMonth).thenReturn(45);
      when(mockProvider.averageCustomerRating).thenReturn(4.5);
      when(mockProvider.formattedRating).thenReturn('4.5');
      when(mockProvider.ratingStars).thenReturn(5);
      when(mockProvider.dailyGrowthPercentage).thenReturn(25.0);
      when(mockProvider.weeklyGrowthPercentage).thenReturn(10.0);
      when(mockProvider.recentOrders).thenReturn([
        {
          'id': 1,
          'customer_name': 'John Doe',
          'total_amount': 89.99,
          'status': 'pending',
          'hike_name': 'Highland Adventure',
        },
        {
          'id': 2,
          'customer_name': 'Jane Smith',
          'total_amount': 79.99,
          'status': 'processing',
          'hike_name': 'Speyside Journey',
        },
      ]);
      when(mockProvider.popularRoutes).thenReturn([
        {'hike_id': 1, 'hike_name': 'Highland Adventure', 'count': 15},
        {'hike_id': 2, 'hike_name': 'Speyside Journey', 'count': 12},
      ]);
      when(mockProvider.refreshData()).thenAnswer((_) async {});
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<DashboardProvider>.value(
          value: mockProvider,
          child: DashboardOverviewPage(),
        ),
      );
    }

    group('Page Structure', () {
      testWidgets('should display page title', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Dashboard'), findsOneWidget);
      });

      testWidgets('should display refresh button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('should call refreshData when refresh button is tapped', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump();

        verify(mockProvider.refreshData()).called(1);
      });
    });

    group('Loading State', () {
      testWidgets('should display loading indicator when loading', (
        WidgetTester tester,
      ) async {
        when(mockProvider.isLoading).thenReturn(true);

        await tester.pumpWidget(createTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading dashboard data...'), findsOneWidget);
      });

      testWidgets('should not display content when loading', (
        WidgetTester tester,
      ) async {
        when(mockProvider.isLoading).thenReturn(true);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Revenue Overview'), findsNothing);
        expect(find.text('Order Management'), findsNothing);
      });
    });

    group('Error State', () {
      testWidgets('should display error message when error exists', (
        WidgetTester tester,
      ) async {
        when(
          mockProvider.errorMessage,
        ).thenReturn('Database connection failed');

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Database connection failed'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      });

      testWidgets('should display retry button when error exists', (
        WidgetTester tester,
      ) async {
        when(mockProvider.errorMessage).thenReturn('Network error');

        await tester.pumpWidget(createTestWidget());

        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should call refreshData when retry button is tapped', (
        WidgetTester tester,
      ) async {
        when(mockProvider.errorMessage).thenReturn('Network error');

        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text('Retry'));
        await tester.pump();

        verify(mockProvider.refreshData()).called(1);
      });
    });

    group('Revenue Overview Section', () {
      testWidgets('should display revenue overview title', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Revenue Overview'), findsOneWidget);
      });

      testWidgets('should display daily revenue card', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Today'), findsOneWidget);
        expect(find.text('150,00 €'), findsOneWidget);
      });

      testWidgets('should display weekly revenue card', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('This Week'), findsOneWidget);
        expect(find.text('800,00 €'), findsOneWidget);
      });

      testWidgets('should display monthly revenue card', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('This Month'), findsOneWidget);
        expect(find.text('3.500,00 €'), findsOneWidget);
      });

      testWidgets('should display growth indicators', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('+25.0%'), findsOneWidget);
        expect(find.text('+10.0%'), findsOneWidget);
      });

      testWidgets('should display negative growth correctly', (
        WidgetTester tester,
      ) async {
        when(mockProvider.dailyGrowthPercentage).thenReturn(-15.0);
        when(mockProvider.weeklyGrowthPercentage).thenReturn(-5.0);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('-15.0%'), findsOneWidget);
        expect(find.text('-5.0%'), findsOneWidget);
      });
    });

    group('Order Management Section', () {
      testWidgets('should display order management title', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Order Management'), findsOneWidget);
      });

      testWidgets('should display total active orders', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Total Active'), findsOneWidget);
        expect(find.text('15'), findsOneWidget);
      });

      testWidgets('should display pending orders', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Pending'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('should display processing orders', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Processing'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
      });

      testWidgets('should display shipped orders', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Shipped'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });
    });

    group('Route Sales Section', () {
      testWidgets('should display route sales title', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Route Sales'), findsOneWidget);
      });

      testWidgets('should display sold routes today', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('2'), findsAtLeastNWidgets(1)); // Today's sales
      });

      testWidgets('should display sold routes this week', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('12'), findsAtLeastNWidgets(1)); // This week's sales
      });

      testWidgets('should display sold routes this month', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('45'), findsAtLeastNWidgets(1)); // This month's sales
      });
    });

    group('Customer Rating Section', () {
      testWidgets('should display customer rating', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Customer Rating'), findsOneWidget);
        expect(find.text('4.5'), findsOneWidget);
      });

      testWidgets('should display rating stars', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.star), findsAtLeastNWidgets(5));
      });
    });

    group('Recent Orders Section', () {
      testWidgets('should display recent orders title', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Recent Orders'), findsOneWidget);
      });

      testWidgets('should display recent order items', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('Highland Adventure'), findsOneWidget);
        expect(find.text('Speyside Journey'), findsOneWidget);
      });

      testWidgets('should display order statuses', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('pending'), findsOneWidget);
        expect(find.text('processing'), findsOneWidget);
      });
    });

    group('Popular Routes Section', () {
      testWidgets('should display popular routes title', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Popular Routes'), findsOneWidget);
      });

      testWidgets('should display popular route items', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Highland Adventure'), findsAtLeastNWidgets(1));
        expect(find.text('Speyside Journey'), findsAtLeastNWidgets(1));
      });

      testWidgets('should display route sales counts', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('15 sales'), findsOneWidget);
        expect(find.text('12 sales'), findsOneWidget);
      });
    });

    group('Empty State Handling', () {
      testWidgets('should display empty state when no revenue data', (
        WidgetTester tester,
      ) async {
        when(mockProvider.hasRevenueData).thenReturn(false);
        when(mockProvider.dailyRevenue).thenReturn(0.0);
        when(mockProvider.weeklyRevenue).thenReturn(0.0);
        when(mockProvider.monthlyRevenue).thenReturn(0.0);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('No revenue data available'), findsOneWidget);
      });

      testWidgets('should display empty state when no orders', (
        WidgetTester tester,
      ) async {
        when(mockProvider.hasRecentOrders).thenReturn(false);
        when(mockProvider.recentOrders).thenReturn([]);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('No recent orders'), findsOneWidget);
      });

      testWidgets('should display empty state when no popular routes', (
        WidgetTester tester,
      ) async {
        when(mockProvider.hasPopularRoutes).thenReturn(false);
        when(mockProvider.popularRoutes).thenReturn([]);

        await tester.pumpWidget(createTestWidget());

        expect(find.text('No popular routes data'), findsOneWidget);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt layout for desktop', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestWidget());

        // Should find grid layout for desktop
        expect(find.byType(GridView), findsOneWidget);
      });

      testWidgets('should adapt layout for mobile', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestWidget());

        // Should find column layout for mobile
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });
  });
}
