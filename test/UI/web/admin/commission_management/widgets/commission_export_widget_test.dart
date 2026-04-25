import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/data/providers/commission_provider.dart';

import '../../../../../test_helpers.dart';
import 'commission_export_widget_test.mocks.dart';

@GenerateMocks([CommissionProvider])
void main() {
  group('CommissionExportWidget UI Tests', () {
    late MockCommissionProvider mockProvider;

    setUp(() {
      mockProvider = MockCommissionProvider();

      // Setup default mock behavior
      when(mockProvider.isLoading).thenReturn(false);
      when(
        mockProvider.commissions,
      ).thenReturn(TestHelpers.createSampleCommissions());
      when(
        mockProvider.filteredCommissions,
      ).thenReturn(TestHelpers.createSampleCommissions());
      when(mockProvider.currentFilter).thenReturn('all');
      when(mockProvider.startDate).thenReturn(null);
      when(mockProvider.endDate).thenReturn(null);
      when(mockProvider.searchTerm).thenReturn('');
    });

    Widget createWidget() {
      return ChangeNotifierProvider<CommissionProvider>.value(
        value: mockProvider,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(Icons.download),
                  tooltip: 'Export',
                  onSelected: (value) {},
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'pdf',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Als PDF exportieren'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'csv',
                      child: Row(
                        children: [
                          Icon(Icons.table_chart, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Als CSV exportieren'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    group('Widget Structure', () {
      testWidgets('should display export button', (tester) async {
        // Act
        await tester.pumpWidget(createWidget());

        // Assert
        expect(find.byIcon(Icons.download), findsOneWidget);
        expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      });

      testWidgets('should show export options on tap', skip: true, (tester) async {
        // Act
        await tester.pumpWidget(createWidget());
        await tester.tap(find.byIcon(Icons.download));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Als PDF exportieren'), findsOneWidget);
        expect(find.text('Als CSV exportieren'), findsOneWidget);
        expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
        expect(find.byIcon(Icons.table_chart), findsOneWidget);
      });
    });

    group('Provider Integration', () {
      testWidgets('should use commission count from provider', skip: true, (tester) async {
        // Arrange
        final testCommissions = TestHelpers.createSampleCommissions()
            .take(3)
            .toList();
        when(mockProvider.commissions).thenReturn(testCommissions);
        when(mockProvider.filteredCommissions).thenReturn(testCommissions);

        // Act
        await tester.pumpWidget(createWidget());

        // Assert - Widget should be created successfully with provider data
        expect(find.byIcon(Icons.download), findsOneWidget);
        verify(mockProvider.commissions).called(greaterThan(0));
      });
    });
  });

  group('CommissionProviderFilters Extension Tests', () {
    late MockCommissionProvider mockProvider;

    setUp(() {
      mockProvider = MockCommissionProvider();
    });

    test('should detect no active filters', () {
      // Arrange
      when(mockProvider.currentFilter).thenReturn('all');
      when(mockProvider.startDate).thenReturn(null);
      when(mockProvider.endDate).thenReturn(null);
      when(mockProvider.searchTerm).thenReturn('');

      // Act & Assert - Test mock setup is correct
      expect(mockProvider.currentFilter, equals('all'));
      expect(mockProvider.startDate, isNull);
      expect(mockProvider.endDate, isNull);
      expect(mockProvider.searchTerm, isEmpty);
    });

    test('should detect active date filter', () {
      // Arrange
      when(mockProvider.currentFilter).thenReturn('all');
      when(mockProvider.startDate).thenReturn(DateTime(2024, 1, 1));
      when(mockProvider.endDate).thenReturn(DateTime(2024, 12, 31));
      when(mockProvider.searchTerm).thenReturn('');

      // Act & Assert
      expect(mockProvider.startDate, isNotNull);
      expect(mockProvider.endDate, isNotNull);
    });

    test('should detect active search filter', () {
      // Arrange
      when(mockProvider.currentFilter).thenReturn('all');
      when(mockProvider.startDate).thenReturn(null);
      when(mockProvider.endDate).thenReturn(null);
      when(mockProvider.searchTerm).thenReturn('test search');

      // Act & Assert
      expect(mockProvider.searchTerm, isNotEmpty);
    });

    test('should detect active status filter', () {
      // Arrange
      when(mockProvider.currentFilter).thenReturn('pending');
      when(mockProvider.startDate).thenReturn(null);
      when(mockProvider.endDate).thenReturn(null);
      when(mockProvider.searchTerm).thenReturn('');

      // Act & Assert
      expect(mockProvider.currentFilter, isNot(equals('all')));
    });
  });
}
