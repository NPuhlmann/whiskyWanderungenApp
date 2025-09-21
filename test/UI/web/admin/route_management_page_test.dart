import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/web/admin/route_management/route_management_page.dart';
import 'package:whisky_hikes/data/providers/route_management_provider.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

@GenerateMocks([RouteManagementProvider])
import 'route_management_page_test.mocks.dart';

void main() {
  group('RouteManagementPage Widget Tests', () {
    late MockRouteManagementProvider mockProvider;

    setUp(() {
      mockProvider = MockRouteManagementProvider();

      // Default mock values
      when(mockProvider.routes).thenReturn([]);
      when(mockProvider.selectedRoute).thenReturn(null);
      when(mockProvider.waypoints).thenReturn([]);
      when(mockProvider.isLoading).thenReturn(false);
      when(mockProvider.isUploading).thenReturn(false);
      when(mockProvider.errorMessage).thenReturn(null);
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('de', 'DE'),
        ],
        home: ChangeNotifierProvider<RouteManagementProvider>.value(
          value: mockProvider,
          child: child,
        ),
      );
    }

    group('Initial State', () {
      testWidgets('should display empty state when no routes available', (tester) async {
        // Arrange
        when(mockProvider.routes).thenReturn([]);
        when(mockProvider.isLoading).thenReturn(false);

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Keine Routen verfügbar'), findsOneWidget);
        expect(find.byIcon(Icons.map_outlined), findsOneWidget);
        expect(find.text('Erstellen Sie Ihre erste Wanderroute'), findsOneWidget);
      });

      testWidgets('should display loading indicator when loading', (tester) async {
        // Arrange
        when(mockProvider.isLoading).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should display error message when error occurs', (tester) async {
        // Arrange
        const errorMessage = 'Failed to load routes';
        when(mockProvider.errorMessage).thenReturn(errorMessage);
        when(mockProvider.routes).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(errorMessage), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      });

      testWidgets('should call loadRoutes on init', (tester) async {
        // Arrange
        when(mockProvider.loadRoutes()).thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        verify(mockProvider.loadRoutes()).called(1);
      });
    });

    group('Route List Display', () {
      testWidgets('should display routes list when routes available', (tester) async {
        // Arrange
        final mockRoutes = [
          {
            'id': 123,
            'name': 'Route 1',
            'description': 'Description 1',
            'difficulty': 'easy',
            'price': 79.99,
            'is_active': true,
            'distance': 8.5,
            'duration': 3,
          },
          {
            'id': 124,
            'name': 'Route 2',
            'description': 'Description 2',
            'difficulty': 'moderate',
            'price': 89.99,
            'is_active': false,
            'distance': 12.3,
            'duration': 5,
          },
        ];

        when(mockProvider.routes).thenReturn(mockRoutes);

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Route 1'), findsOneWidget);
        expect(find.text('Route 2'), findsOneWidget);
        expect(find.text('79,99 €'), findsOneWidget);
        expect(find.text('89,99 €'), findsOneWidget);
        expect(find.text('8,5 km'), findsOneWidget);
        expect(find.text('12,3 km'), findsOneWidget);
      });

      testWidgets('should show active/inactive status correctly', (tester) async {
        // Arrange
        final mockRoutes = [
          {
            'id': 123,
            'name': 'Active Route',
            'is_active': true,
            'price': 79.99,
            'distance': 8.5,
            'duration': 3,
          },
          {
            'id': 124,
            'name': 'Inactive Route',
            'is_active': false,
            'price': 89.99,
            'distance': 12.3,
            'duration': 5,
          },
        ];

        when(mockProvider.routes).thenReturn(mockRoutes);

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Aktiv'), findsOneWidget);
        expect(find.text('Inaktiv'), findsOneWidget);
      });

      testWidgets('should display difficulty badges correctly', (tester) async {
        // Arrange
        final mockRoutes = [
          {
            'id': 123,
            'name': 'Easy Route',
            'difficulty': 'easy',
            'price': 79.99,
            'distance': 8.5,
            'duration': 3,
          },
          {
            'id': 124,
            'name': 'Hard Route',
            'difficulty': 'hard',
            'price': 89.99,
            'distance': 12.3,
            'duration': 5,
          },
        ];

        when(mockProvider.routes).thenReturn(mockRoutes);

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Leicht'), findsOneWidget);
        expect(find.text('Schwer'), findsOneWidget);
      });
    });

    group('Route Actions', () {
      testWidgets('should show route action buttons', (tester) async {
        // Arrange
        final mockRoutes = [
          {
            'id': 123,
            'name': 'Test Route',
            'price': 79.99,
            'distance': 8.5,
            'duration': 3,
            'is_active': true,
          },
        ];

        when(mockProvider.routes).thenReturn(mockRoutes);

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.byIcon(Icons.map), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('should call selectRoute when route is tapped', (tester) async {
        // Arrange
        final mockRoute = {
          'id': 123,
          'name': 'Test Route',
          'price': 79.99,
          'distance': 8.5,
          'duration': 3,
          'is_active': true,
        };

        when(mockProvider.routes).thenReturn([mockRoute]);
        when(mockProvider.selectRoute(any)).thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Test Route'));
        await tester.pumpAndSettle();

        // Assert
        verify(mockProvider.selectRoute(mockRoute)).called(1);
      });

      testWidgets('should show delete confirmation dialog', (tester) async {
        // Arrange
        final mockRoute = {
          'id': 123,
          'name': 'Test Route',
          'price': 79.99,
          'distance': 8.5,
          'duration': 3,
          'is_active': true,
        };

        when(mockProvider.routes).thenReturn([mockRoute]);

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Route löschen'), findsOneWidget);
        expect(find.text('Möchten Sie diese Route wirklich löschen?'), findsOneWidget);
        expect(find.text('Abbrechen'), findsOneWidget);
        expect(find.text('Löschen'), findsOneWidget);
      });

      testWidgets('should call deleteRoute when confirmed', (tester) async {
        // Arrange
        final mockRoute = {
          'id': 123,
          'name': 'Test Route',
          'price': 79.99,
          'distance': 8.5,
          'duration': 3,
          'is_active': true,
        };

        when(mockProvider.routes).thenReturn([mockRoute]);
        when(mockProvider.deleteRoute(123)).thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Löschen'));
        await tester.pumpAndSettle();

        // Assert
        verify(mockProvider.deleteRoute(123)).called(1);
      });
    });

    group('Create New Route', () {
      testWidgets('should show create route button', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Neue Route'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('should open create route dialog when button is tapped', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Neue Route'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Neue Route erstellen'), findsOneWidget);
      });
    });

    group('Search and Filter', () {
      testWidgets('should show search field', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(TextField), findsAtLeastNWidgets(1));
        expect(find.text('Routen suchen...'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('should filter routes based on search text', (tester) async {
        // Arrange
        final mockRoutes = [
          {
            'id': 123,
            'name': 'Highland Route',
            'price': 79.99,
            'distance': 8.5,
            'duration': 3,
          },
          {
            'id': 124,
            'name': 'Speyside Adventure',
            'price': 89.99,
            'distance': 12.3,
            'duration': 5,
          },
        ];

        when(mockProvider.routes).thenReturn(mockRoutes);

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Highland');
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Highland Route'), findsOneWidget);
        expect(find.text('Speyside Adventure'), findsNothing);
      });

      testWidgets('should show filter chips', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Alle'), findsOneWidget);
        expect(find.text('Aktiv'), findsOneWidget);
        expect(find.text('Inaktiv'), findsOneWidget);
        expect(find.text('Leicht'), findsOneWidget);
        expect(find.text('Mittel'), findsOneWidget);
        expect(find.text('Schwer'), findsOneWidget);
      });
    });

    group('Responsive Layout', () {
      testWidgets('should show grid layout on desktop', (tester) async {
        // Arrange
        final mockRoutes = [
          {
            'id': 123,
            'name': 'Test Route',
            'price': 79.99,
            'distance': 8.5,
            'duration': 3,
          },
        ];

        when(mockProvider.routes).thenReturn(mockRoutes);

        // Act
        await tester.binding.setSurfaceSize(const Size(1200, 800)); // Desktop size
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(GridView), findsOneWidget);
      });

      testWidgets('should show list layout on mobile', (tester) async {
        // Arrange
        final mockRoutes = [
          {
            'id': 123,
            'name': 'Test Route',
            'price': 79.99,
            'distance': 8.5,
            'duration': 3,
          },
        ];

        when(mockProvider.routes).thenReturn(mockRoutes);

        // Act
        await tester.binding.setSurfaceSize(const Size(400, 800)); // Mobile size
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should show retry button when error occurs', (tester) async {
        // Arrange
        when(mockProvider.errorMessage).thenReturn('Network error');
        when(mockProvider.routes).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Erneut versuchen'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('should call loadRoutes when retry button is tapped', (tester) async {
        // Arrange
        when(mockProvider.errorMessage).thenReturn('Network error');
        when(mockProvider.routes).thenReturn([]);
        when(mockProvider.loadRoutes()).thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Erneut versuchen'));
        await tester.pumpAndSettle();

        // Assert
        verify(mockProvider.loadRoutes()).called(2); // Once on init, once on retry
      });

      testWidgets('should clear error when clearError is called', (tester) async {
        // Arrange
        when(mockProvider.errorMessage).thenReturn('Network error');
        when(mockProvider.routes).thenReturn([]);
        when(mockProvider.clearError()).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();

        // Find and tap close button on error snackbar/banner
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        // Assert
        verify(mockProvider.clearError()).called(1);
      });
    });

    group('Performance', () {
      testWidgets('should handle large number of routes efficiently', (tester) async {
        // Arrange
        final mockRoutes = List.generate(100, (index) => {
          'id': index,
          'name': 'Route $index',
          'price': 79.99 + index,
          'distance': 8.5 + index,
          'duration': 3 + (index % 5),
          'is_active': index % 2 == 0,
        });

        when(mockProvider.routes).thenReturn(mockRoutes);

        // Act
        final stopwatch = Stopwatch()..start();
        await tester.pumpWidget(createTestWidget(const RouteManagementPage()));
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should render within 1 second
        expect(find.text('Route 0'), findsOneWidget);
      });
    });
  });
}