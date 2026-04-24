import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/web/admin/commission_management/widgets/commission_filter_widget.dart';
import 'package:whisky_hikes/data/providers/commission_provider.dart';

// Create mock provider
class MockCommissionProvider extends Mock implements CommissionProvider {}

void main() {
  group('CommissionFilterWidget Tests', () {
    late MockCommissionProvider mockProvider;

    setUp(() {
      mockProvider = MockCommissionProvider();

      // Setup default returns
      when(mockProvider.currentFilter).thenReturn('all');
      when(mockProvider.searchTerm).thenReturn('');
      when(mockProvider.startDate).thenReturn(null);
      when(mockProvider.endDate).thenReturn(null);
      when(mockProvider.selectedPeriod).thenReturn('month');
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<CommissionProvider>.value(
            value: mockProvider,
            child: const CommissionFilterWidget(),
          ),
        ),
      );
    }

    group('Filter Components', () {
      testWidgets('should display all filter controls', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Status'), findsOneWidget);
        expect(find.text('Suchbegriff'), findsOneWidget);
        expect(find.text('Zeitraum'), findsOneWidget);
        expect(
          find.byType(DropdownButton<String>),
          findsAtLeastNWidgets(2),
        ); // Status + Period
        expect(find.byType(TextField), findsOneWidget); // Search field
      });

      testWidgets('should display status filter dropdown', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Find and tap status dropdown
        final statusDropdown = find
            .byKey(const Key('status_filter_dropdown'))
            .first;
        await tester.tap(statusDropdown);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Alle'), findsOneWidget);
        expect(find.text('Ausstehend'), findsOneWidget);
        expect(find.text('Berechnet'), findsOneWidget);
        expect(find.text('Bezahlt'), findsOneWidget);
        expect(find.text('Storniert'), findsOneWidget);
      });

      testWidgets('should display period filter dropdown', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Find and tap period dropdown
        final periodDropdown = find
            .byKey(const Key('period_filter_dropdown'))
            .first;
        await tester.tap(periodDropdown);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Diese Woche'), findsOneWidget);
        expect(find.text('Dieser Monat'), findsOneWidget);
        expect(find.text('Letzter Monat'), findsOneWidget);
        expect(find.text('Dieses Jahr'), findsOneWidget);
        expect(find.text('Benutzerdefiniert'), findsOneWidget);
      });

      testWidgets('should display search text field', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final searchField = find.byKey(const Key('search_text_field'));
        expect(searchField, findsOneWidget);

        final textField = tester.widget<TextField>(searchField);
        expect(
          textField.decoration?.hintText,
          'Nach Unternehmen oder Bestellung suchen...',
        );
      });
    });

    group('Filter Interactions', () {
      testWidgets('should call provider when status filter changes', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Find and tap status dropdown
        final statusDropdown = find
            .byKey(const Key('status_filter_dropdown'))
            .first;
        await tester.tap(statusDropdown);
        await tester.pumpAndSettle();

        // Select 'Ausstehend'
        await tester.tap(find.text('Ausstehend').last);
        await tester.pumpAndSettle();

        // Assert
        verify(mockProvider.setFilter('pending')).called(1);
      });

      testWidgets('should call provider when search term changes', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Find search field and enter text
        final searchField = find.byKey(const Key('search_text_field'));
        await tester.enterText(searchField, 'test search');
        await tester.pump(
          const Duration(milliseconds: 600),
        ); // Wait for debounce

        // Assert
        verify(mockProvider.setSearchTerm('test search')).called(1);
      });

      testWidgets('should call provider when period changes', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Find and tap period dropdown
        final periodDropdown = find
            .byKey(const Key('period_filter_dropdown'))
            .first;
        await tester.tap(periodDropdown);
        await tester.pumpAndSettle();

        // Select 'Diese Woche'
        await tester.tap(find.text('Diese Woche').last);
        await tester.pumpAndSettle();

        // Assert
        verify(mockProvider.setDateRange(any, any)).called(1);
      });

      testWidgets('should show date pickers for custom period', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Select custom period
        final periodDropdown = find
            .byKey(const Key('period_filter_dropdown'))
            .first;
        await tester.tap(periodDropdown);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Benutzerdefiniert').last);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Von'), findsOneWidget);
        expect(find.text('Bis'), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today), findsAtLeastNWidgets(2));
      });
    });

    group('Clear Filters', () {
      testWidgets('should show clear filters button when filters are active', (
        tester,
      ) async {
        // Arrange
        when(mockProvider.currentFilter).thenReturn('pending');
        when(mockProvider.searchTerm).thenReturn('test');

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Filter zurücksetzen'), findsOneWidget);
        expect(find.byIcon(Icons.clear_all), findsOneWidget);
      });

      testWidgets(
        'should hide clear filters button when no filters are active',
        (tester) async {
          // Arrange - default setup has no active filters

          // Act
          await tester.pumpWidget(createTestWidget());

          // Assert
          expect(find.text('Filter zurücksetzen'), findsNothing);
        },
      );

      testWidgets('should clear all filters when clear button is tapped', (
        tester,
      ) async {
        // Arrange
        when(mockProvider.currentFilter).thenReturn('pending');
        when(mockProvider.searchTerm).thenReturn('test');

        // Act
        await tester.pumpWidget(createTestWidget());

        final clearButton = find.text('Filter zurücksetzen');
        expect(clearButton, findsOneWidget);

        await tester.tap(clearButton);

        // Assert
        verify(mockProvider.setFilter('all')).called(1);
        verify(mockProvider.setSearchTerm('')).called(1);
        verify(mockProvider.setDateRange(null, null)).called(1);
      });
    });

    group('Responsive Layout', () {
      testWidgets('should adapt to mobile layout', (tester) async {
        // Arrange - Force mobile screen size
        await tester.binding.setSurfaceSize(const Size(400, 800));

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Column), findsWidgets);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should adapt to desktop layout', (tester) async {
        // Arrange - Force desktop screen size
        await tester.binding.setSurfaceSize(const Size(1200, 800));

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Row), findsWidgets);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Search Debouncing', () {
      testWidgets('should debounce search input', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        final searchField = find.byKey(const Key('search_text_field'));

        // Enter text multiple times quickly
        await tester.enterText(searchField, 'a');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.enterText(searchField, 'ab');
        await tester.pump(const Duration(milliseconds: 100));
        await tester.enterText(searchField, 'abc');

        // Wait for debounce period
        await tester.pump(const Duration(milliseconds: 600));

        // Assert - should only call once with final text
        verify(mockProvider.setSearchTerm('abc')).called(1);
        verifyNever(mockProvider.setSearchTerm('a'));
        verifyNever(mockProvider.setSearchTerm('ab'));
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper labels for screen readers', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byTooltip('Status filtern'), findsOneWidget);
        expect(find.byTooltip('Zeitraum filtern'), findsOneWidget);
        expect(
          find.byTooltip('Filter zurücksetzen'),
          findsNothing,
        ); // Only shown when filters active
      });
    });
  });
}
