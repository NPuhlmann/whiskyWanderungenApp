import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/web/admin/commission_management/widgets/commission_list_widget.dart';
import 'package:whisky_hikes/data/providers/commission_provider.dart';
import 'package:whisky_hikes/domain/models/commission.dart';
import '../../../../../test_helpers.dart';

// Create mock provider
class MockCommissionProvider extends Mock implements CommissionProvider {}

void main() {
  group('CommissionListWidget Tests', () {
    late MockCommissionProvider mockProvider;

    setUp(() {
      mockProvider = MockCommissionProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<CommissionProvider>.value(
            value: mockProvider,
            child: const CommissionListWidget(),
          ),
        ),
      );
    }

    group('Loading States', () {
      testWidgets(
        'should show loading indicator when loading and no commissions',
        (tester) async {
          // Arrange
          when(mockProvider.isLoading).thenReturn(true);
          when(mockProvider.commissions).thenReturn([]);
          when(mockProvider.filteredCommissions).thenReturn([]);
          when(mockProvider.errorMessage).thenReturn(null);

          // Act
          await tester.pumpWidget(createTestWidget());

          // Assert
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(find.text('Keine Provisionen gefunden'), findsNothing);
        },
      );

      testWidgets(
        'should show commissions when loading but commissions exist',
        (tester) async {
          // Arrange
          final commissions = TestHelpers.createSampleCommissions();
          when(mockProvider.isLoading).thenReturn(true);
          when(mockProvider.commissions).thenReturn(commissions);
          when(mockProvider.filteredCommissions).thenReturn(commissions);
          when(mockProvider.errorMessage).thenReturn(null);

          // Act
          await tester.pumpWidget(createTestWidget());

          // Assert
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.text('Keine Provisionen gefunden'), findsNothing);
          // Should show commission cards/list
        },
      );
    });

    group('Error States', () {
      testWidgets('should show error message when error occurs', (
        tester,
      ) async {
        // Arrange
        const errorMessage = 'Failed to load commissions';
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.commissions).thenReturn([]);
        when(mockProvider.filteredCommissions).thenReturn([]);
        when(mockProvider.errorMessage).thenReturn(errorMessage);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Fehler beim Laden der Provisionen'), findsOneWidget);
        expect(find.text(errorMessage), findsOneWidget);
      });

      testWidgets('should show retry button on error', (tester) async {
        // Arrange
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.commissions).thenReturn([]);
        when(mockProvider.filteredCommissions).thenReturn([]);
        when(mockProvider.errorMessage).thenReturn('Error message');

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Wiederholen'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('Empty States', () {
      testWidgets('should show empty message when no commissions', (
        tester,
      ) async {
        // Arrange
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.commissions).thenReturn([]);
        when(mockProvider.filteredCommissions).thenReturn([]);
        when(mockProvider.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Keine Provisionen gefunden'), findsOneWidget);
        expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      });

      testWidgets(
        'should show filtered empty message when no filtered results',
        (tester) async {
          // Arrange
          final allCommissions = TestHelpers.createSampleCommissions();
          when(mockProvider.isLoading).thenReturn(false);
          when(mockProvider.commissions).thenReturn(allCommissions);
          when(mockProvider.filteredCommissions).thenReturn([]);
          when(mockProvider.errorMessage).thenReturn(null);

          // Act
          await tester.pumpWidget(createTestWidget());

          // Assert
          expect(
            find.text('Keine Provisionen entsprechen den Filterkriterien'),
            findsOneWidget,
          );
        },
      );
    });

    group('Commission Display', () {
      testWidgets('should display commission cards on mobile', (tester) async {
        // Arrange
        final commissions = TestHelpers.createSampleCommissions();
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.commissions).thenReturn(commissions);
        when(mockProvider.filteredCommissions).thenReturn(commissions);
        when(mockProvider.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Card), findsWidgets);

        // Check if first commission data is displayed
        final firstCommission = commissions.first;
        expect(
          find.text(firstCommission.formattedCommissionAmount),
          findsOneWidget,
        );
      });

      testWidgets('should display commission table on desktop', (tester) async {
        // Arrange
        final commissions = TestHelpers.createSampleCommissions();
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.commissions).thenReturn(commissions);
        when(mockProvider.filteredCommissions).thenReturn(commissions);
        when(mockProvider.errorMessage).thenReturn(null);

        // Force large screen size
        await tester.binding.setSurfaceSize(const Size(1200, 800));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(DataTable), findsOneWidget);

        // Check table headers
        expect(find.text('Provision'), findsOneWidget);
        expect(find.text('Grundbetrag'), findsOneWidget);
        expect(find.text('Status'), findsOneWidget);
        expect(find.text('Erstellt'), findsOneWidget);
        expect(find.text('Aktionen'), findsOneWidget);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should show commission status chips', (tester) async {
        // Arrange
        final commissions = TestHelpers.createSampleCommissions();
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.commissions).thenReturn(commissions);
        when(mockProvider.filteredCommissions).thenReturn(commissions);
        when(mockProvider.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        // Should find status chips for different commission statuses
        expect(find.text('Ausstehend'), findsWidgets);
        expect(find.text('Bezahlt'), findsWidgets);
        expect(find.text('Berechnet'), findsWidgets);
      });
    });

    group('Interactions', () {
      testWidgets('should open commission details on tap', (tester) async {
        // Arrange
        final commissions = TestHelpers.createSampleCommissions();
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.commissions).thenReturn(commissions);
        when(mockProvider.filteredCommissions).thenReturn(commissions);
        when(mockProvider.errorMessage).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find first commission card/row and tap it
        final firstCard = find.byType(Card).first;
        await tester.tap(firstCard);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Provisions-Details'), findsOneWidget);
        expect(find.byType(Dialog), findsOneWidget);
      });

      testWidgets('should handle retry action on error', (tester) async {
        // Arrange
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.commissions).thenReturn([]);
        when(mockProvider.filteredCommissions).thenReturn([]);
        when(mockProvider.errorMessage).thenReturn('Error');

        // Act
        await tester.pumpWidget(createTestWidget());

        final retryButton = find.text('Wiederholen');
        expect(retryButton, findsOneWidget);

        await tester.tap(retryButton);

        // Assert
        verify(mockProvider.loadCommissionsForCompany(any)).called(1);
      });
    });

    group('Responsive Layout', () {
      testWidgets('should use cards on mobile layout', (tester) async {
        // Arrange
        final commissions = TestHelpers.createSampleCommissions();
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.commissions).thenReturn(commissions);
        when(mockProvider.filteredCommissions).thenReturn(commissions);
        when(mockProvider.errorMessage).thenReturn(null);

        // Force mobile screen size
        await tester.binding.setSurfaceSize(const Size(400, 800));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(Card), findsWidgets);
        expect(find.byType(DataTable), findsNothing);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should use table on desktop layout', (tester) async {
        // Arrange
        final commissions = TestHelpers.createSampleCommissions();
        when(mockProvider.isLoading).thenReturn(false);
        when(mockProvider.commissions).thenReturn(commissions);
        when(mockProvider.filteredCommissions).thenReturn(commissions);
        when(mockProvider.errorMessage).thenReturn(null);

        // Force desktop screen size
        await tester.binding.setSurfaceSize(const Size(1200, 800));

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(DataTable), findsOneWidget);
        expect(find.byType(Card), findsNothing);

        // Reset surface size
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}
