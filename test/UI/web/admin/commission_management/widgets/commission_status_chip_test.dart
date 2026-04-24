import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/UI/web/admin/commission_management/widgets/commission_status_chip.dart';
import 'package:whisky_hikes/domain/models/commission.dart';

void main() {
  group('CommissionStatusChip Tests', () {
    Widget createTestWidget({
      required CommissionStatus status,
      bool showAction = false,
      VoidCallback? onStatusChange,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CommissionStatusChip(
            status: status,
            showAction: showAction,
            onStatusChange: onStatusChange,
          ),
        ),
      );
    }

    group('Visual Display', () {
      testWidgets('should display correct text for pending status', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.pending),
        );

        // Assert
        expect(find.text('Ausstehend'), findsOneWidget);
        expect(find.byType(Chip), findsOneWidget);
      });

      testWidgets('should display correct text for calculated status', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.calculated),
        );

        // Assert
        expect(find.text('Berechnet'), findsOneWidget);
      });

      testWidgets('should display correct text for paid status', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.paid),
        );

        // Assert
        expect(find.text('Bezahlt'), findsOneWidget);
      });

      testWidgets('should display correct text for cancelled status', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.cancelled),
        );

        // Assert
        expect(find.text('Storniert'), findsOneWidget);
      });
    });

    group('Color Coding', () {
      testWidgets('should use correct color for pending status', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.pending),
        );

        // Assert
        final chip = tester.widget<Chip>(find.byType(Chip));
        expect(chip.backgroundColor, Colors.orange.shade100);
      });

      testWidgets('should use correct color for calculated status', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.calculated),
        );

        // Assert
        final chip = tester.widget<Chip>(find.byType(Chip));
        expect(chip.backgroundColor, Colors.blue.shade100);
      });

      testWidgets('should use correct color for paid status', (tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.paid),
        );

        // Assert
        final chip = tester.widget<Chip>(find.byType(Chip));
        expect(chip.backgroundColor, Colors.green.shade100);
      });

      testWidgets('should use correct color for cancelled status', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.cancelled),
        );

        // Assert
        final chip = tester.widget<Chip>(find.byType(Chip));
        expect(chip.backgroundColor, Colors.red.shade100);
      });
    });

    group('Interactive Behavior', () {
      testWidgets('should be non-interactive by default', (tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.pending),
        );

        // Assert
        final chip = tester.widget<Chip>(find.byType(Chip));
        expect(chip.onDeleted, isNull);
      });

      testWidgets('should show action button when showAction is true', (
        tester,
      ) async {
        // Arrange
        bool callbackCalled = false;
        void onStatusChange() {
          callbackCalled = true;
        }

        // Act
        await tester.pumpWidget(
          createTestWidget(
            status: CommissionStatus.pending,
            showAction: true,
            onStatusChange: onStatusChange,
          ),
        );

        // Assert
        expect(find.byIcon(Icons.edit), findsOneWidget);

        // Tap the action button
        await tester.tap(find.byIcon(Icons.edit));
        expect(callbackCalled, isTrue);
      });

      testWidgets('should not show action button when showAction is false', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.pending, showAction: false),
        );

        // Assert
        expect(find.byIcon(Icons.edit), findsNothing);
      });

      testWidgets('should handle null callback gracefully', (tester) async {
        // Act & Assert (should not throw)
        await tester.pumpWidget(
          createTestWidget(
            status: CommissionStatus.pending,
            showAction: true,
            onStatusChange: null,
          ),
        );

        expect(find.byType(Chip), findsOneWidget);
      });
    });

    group('Icons', () {
      testWidgets('should show correct icon for pending status', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.pending),
        );

        // Assert
        expect(find.byIcon(Icons.pending), findsOneWidget);
      });

      testWidgets('should show correct icon for calculated status', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.calculated),
        );

        // Assert
        expect(find.byIcon(Icons.calculate), findsOneWidget);
      });

      testWidgets('should show correct icon for paid status', (tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.paid),
        );

        // Assert
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('should show correct icon for cancelled status', (
        tester,
      ) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.cancelled),
        );

        // Assert
        expect(find.byIcon(Icons.cancel), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantics', (tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.pending),
        );

        // Assert
        expect(find.byTooltip('Status: Ausstehend'), findsOneWidget);
      });

      testWidgets('should support screen readers', (tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(status: CommissionStatus.paid),
        );

        // Assert
        final chip = tester.widget<Chip>(find.byType(Chip));
        expect(chip.semanticLabel, 'Provision Status: Bezahlt');
      });
    });
  });
}
