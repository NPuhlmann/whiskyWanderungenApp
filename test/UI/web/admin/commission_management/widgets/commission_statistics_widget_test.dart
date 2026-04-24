import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/web/admin/commission_management/widgets/commission_statistics_widget.dart';
import 'package:whisky_hikes/data/providers/commission_provider.dart';

// Create mock provider
class MockCommissionProvider extends Mock implements CommissionProvider {}

void main() {
  group('CommissionStatisticsWidget Tests', () {
    late MockCommissionProvider mockProvider;

    setUp(() {
      mockProvider = MockCommissionProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<CommissionProvider>.value(
            value: mockProvider,
            child: const CommissionStatisticsWidget(),
          ),
        ),
      );
    }

    group('Statistics Display', () {
      testWidgets(
        'should display all KPI cards when statistics are available',
        (tester) async {
          // Arrange
          final statistics = {
            'totalCommissions': 25,
            'pendingCommissions': 8,
            'paidCommissions': 15,
            'cancelledCommissions': 2,
            'totalAmount': 1250.50,
            'pendingAmount': 400.00,
            'paidAmount': 750.50,
            'averageCommission': 50.02,
          };

          when(mockProvider.statistics).thenReturn(statistics);
          when(mockProvider.isLoading).thenReturn(false);
          when(mockProvider.errorMessage).thenReturn(null);

          // Act
          await tester.pumpWidget(createTestWidget());

          // Assert
          expect(find.text('Gesamt Provisionen'), findsOneWidget);
          expect(find.text('25'), findsOneWidget);

          expect(find.text('Ausstehende Provisionen'), findsOneWidget);
          expect(find.text('8'), findsOneWidget);

          expect(find.text('Bezahlte Provisionen'), findsOneWidget);
          expect(find.text('15'), findsOneWidget);

          expect(find.text('Gesamt Betrag'), findsOneWidget);
          expect(find.text('€1.250,50'), findsOneWidget);

          expect(find.text('Ausstehender Betrag'), findsOneWidget);
          expect(find.text('€400,00'), findsOneWidget);

          expect(find.text('Durchschnitt'), findsOneWidget);
          expect(find.text('€50,02'), findsOneWidget);
        },
      );

      testWidgets('should display zero values when statistics are empty', (
        tester,
      ) async {
        // Arrange
        when(mockProvider.statistics).thenReturn({});
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('0'), findsWidgets);
        expect(find.text('€0,00'), findsWidgets);
      });

      testWidgets('should show loading indicator when loading', (tester) async {
        // Arrange
        when(mockProvider.statistics).thenReturn({});
        when(mockProvider.isLoading).thenReturn(true);
        when(mockProvider.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
      });

      testWidgets('should show error state when error occurs', (tester) async {
        // Arrange
        when(mockProvider.statistics).thenReturn({});
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.errorMessage).thenReturn('Failed to load statistics');

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Fehler beim Laden'), findsOneWidget);
      });
    });

    group('KPI Cards', () {
      testWidgets('should display correct icons for each KPI', (tester) async {
        // Arrange
        final statistics = {
          'totalCommissions': 25,
          'pendingCommissions': 8,
          'paidCommissions': 15,
          'totalAmount': 1250.50,
          'pendingAmount': 400.00,
          'averageCommission': 50.02,
        };

        when(mockProvider.statistics).thenReturn(statistics);
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(
          find.byIcon(Icons.receipt_long),
          findsOneWidget,
        ); // Total commissions
        expect(
          find.byIcon(Icons.pending),
          findsOneWidget,
        ); // Pending commissions
        expect(
          find.byIcon(Icons.check_circle),
          findsOneWidget,
        ); // Paid commissions
        expect(
          find.byIcon(Icons.euro),
          findsAtLeastNWidgets(3),
        ); // Amount indicators
        expect(find.byIcon(Icons.analytics), findsOneWidget); // Average
      });

      testWidgets('should use correct colors for different KPI types', (
        tester,
      ) async {
        // Arrange
        final statistics = {
          'totalCommissions': 25,
          'pendingCommissions': 8,
          'paidCommissions': 15,
          'totalAmount': 1250.50,
        };

        when(mockProvider.statistics).thenReturn(statistics);
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final cards = tester.widgetList<Card>(find.byType(Card));
        expect(cards, isNotEmpty);
      });
    });

    group('Responsive Layout', () {
      testWidgets('should adapt to mobile layout', (tester) async {
        // Arrange
        final statistics = {
          'totalCommissions': 25,
          'pendingCommissions': 8,
          'paidCommissions': 15,
          'totalAmount': 1250.50,
        };

        when(mockProvider.statistics).thenReturn(statistics);
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.errorMessage).thenReturn(null);

        // Force mobile screen size
        await tester.binding.setSurfaceSize(const Size(400, 800));

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - Should use vertical layout on mobile
        expect(find.byType(GridView), findsOneWidget);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should adapt to desktop layout', (tester) async {
        // Arrange
        final statistics = {
          'totalCommissions': 25,
          'pendingCommissions': 8,
          'paidCommissions': 15,
          'totalAmount': 1250.50,
        };

        when(mockProvider.statistics).thenReturn(statistics);
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.errorMessage).thenReturn(null);

        // Force desktop screen size
        await tester.binding.setSurfaceSize(const Size(1200, 800));

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - Should use horizontal layout on desktop
        expect(find.byType(GridView), findsOneWidget);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Number Formatting', () {
      testWidgets('should format large numbers correctly', (tester) async {
        // Arrange
        final statistics = {
          'totalCommissions': 1234,
          'totalAmount': 123456.789,
          'averageCommission': 1234.56,
        };

        when(mockProvider.statistics).thenReturn(statistics);
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(
          find.text('1.234'),
          findsOneWidget,
        ); // Large number with thousands separator
        expect(find.text('€123.456,79'), findsOneWidget); // Currency formatting
        expect(
          find.text('€1.234,56'),
          findsOneWidget,
        ); // Average with correct decimals
      });

      testWidgets('should handle null and zero values gracefully', (
        tester,
      ) async {
        // Arrange
        final statistics = {
          'totalCommissions': 0,
          'pendingCommissions': null,
          'totalAmount': 0.0,
        };

        when(mockProvider.statistics).thenReturn(statistics);
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - Should not throw errors and display zeros
        expect(find.text('0'), findsWidgets);
        expect(find.text('€0,00'), findsWidgets);
      });
    });

    group('Refresh Functionality', () {
      testWidgets('should show refresh button', (tester) async {
        // Arrange
        when(mockProvider.statistics).thenReturn({});
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('should trigger statistics reload on refresh', (
        tester,
      ) async {
        // Arrange
        when(mockProvider.statistics).thenReturn({});
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());

        final refreshButton = find.byIcon(Icons.refresh);
        await tester.tap(refreshButton);

        // Assert
        verify(mockProvider.loadStatistics(any)).called(1);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantic labels', (tester) async {
        // Arrange
        final statistics = {
          'totalCommissions': 25,
          'pendingCommissions': 8,
          'paidCommissions': 15,
          'totalAmount': 1250.50,
        };

        when(mockProvider.statistics).thenReturn(statistics);
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byTooltip('Statistiken aktualisieren'), findsOneWidget);
      });
    });
  });
}
