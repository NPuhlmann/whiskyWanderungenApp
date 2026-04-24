import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/UI/web/admin/route_management/route_management_page.dart';
import 'package:whisky_hikes/data/providers/route_management_provider.dart';
import 'package:whisky_hikes/data/services/admin/route_management_service.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

@GenerateMocks([SupabaseClient, RouteManagementService])
import 'route_management_integration_test.mocks.dart';

void main() {
  group('Route Management Integration Tests', () {
    late MockSupabaseClient mockClient;
    late MockRouteManagementService mockService;
    late RouteManagementProvider provider;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockService = MockRouteManagementService();
      provider = RouteManagementProvider(routeManagementService: mockService);
    });

    Widget createTestApp({required Widget child}) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
        home: ChangeNotifierProvider<RouteManagementProvider>.value(
          value: provider,
          child: child,
        ),
      );
    }

    group('Complete Route Management Workflow', () {
      testWidgets('should complete full route creation workflow', (
        tester,
      ) async {
        // Arrange
        final mockRoutes = <Map<String, dynamic>>[];
        final newRoute = {
          'id': 123,
          'name': 'Integration Test Route',
          'description': 'Test Description',
          'difficulty': 'moderate',
          'distance': 10.5,
          'duration': 240,
          'price': 89.99,
          'max_participants': 12,
          'is_active': true,
          'created_at': '2024-01-01T10:00:00Z',
          'updated_at': '2024-01-01T10:00:00Z',
        };

        when(
          mockService.getAllRoutesForAdmin(),
        ).thenAnswer((_) async => mockRoutes);

        when(mockService.createRoute(any)).thenAnswer((_) async => newRoute);

        when(mockService.validateRouteData(any)).thenReturn(true);

        // Act - Start with empty state
        await tester.pumpWidget(
          createTestApp(child: const RouteManagementPage()),
        );
        await tester.pumpAndSettle();

        // Verify empty state
        expect(find.text('Keine Routen verfügbar'), findsOneWidget);
        expect(
          find.text('Erstellen Sie Ihre erste Wanderroute'),
          findsOneWidget,
        );

        // Tap create route button
        await tester.tap(find.text('Erste Route erstellen'));
        await tester.pumpAndSettle();

        // Verify dialog opened
        expect(find.text('Neue Route erstellen'), findsOneWidget);

        // Fill out form
        await tester.enterText(
          find.widgetWithText(TextFormField, null).first,
          'Integration Test Route',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, null).at(1),
          'Test Description',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, null).at(2),
          '10.5',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, null).at(3),
          '240',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, null).at(4),
          '89.99',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, null).at(5),
          '12',
        );

        // Mock successful creation and reload
        mockRoutes.add(newRoute);
        when(
          mockService.getAllRoutesForAdmin(),
        ).thenAnswer((_) async => mockRoutes);

        // Submit form
        await tester.tap(find.text('Erstellen'));
        await tester.pumpAndSettle();

        // Verify route was created
        verify(mockService.createRoute(any)).called(1);
        verify(mockService.getAllRoutesForAdmin()).called(atLeast(2));

        // Verify success message
        expect(find.text('Route erfolgreich erstellt'), findsOneWidget);

        // Verify route appears in list
        expect(find.text('Integration Test Route'), findsOneWidget);
        expect(find.text('89,99 €'), findsOneWidget);
      });

      testWidgets('should complete full waypoint management workflow', (
        tester,
      ) async {
        // Arrange
        final mockRoute = {
          'id': 123,
          'name': 'Test Route',
          'description': 'Test Description',
          'difficulty': 'moderate',
          'distance': 10.5,
          'duration': 240,
          'price': 89.99,
          'is_active': true,
        };

        final mockWaypoints = <Map<String, dynamic>>[];

        when(
          mockService.getAllRoutesForAdmin(),
        ).thenAnswer((_) async => [mockRoute]);

        when(
          mockService.getRouteWaypoints(123),
        ).thenAnswer((_) async => mockWaypoints);

        when(mockService.validateWaypointData(any)).thenReturn(true);

        // Start with route selected
        provider.routes.add(mockRoute);
        await provider.selectRoute(mockRoute);

        await tester.pumpWidget(
          createTestApp(child: const RouteManagementPage()),
        );
        await tester.pumpAndSettle();

        // Verify route is selected and waypoint panel is visible
        expect(find.text('Test Route'), findsOneWidget);
        expect(find.text('Wegpunkte verwalten'), findsOneWidget);
        expect(find.text('Keine Wegpunkte'), findsOneWidget);

        // Add first waypoint
        await tester.tap(find.text('Ersten Wegpunkt hinzufügen'));
        await tester.pumpAndSettle();

        // Verify waypoint dialog
        expect(find.text('Wegpunkt hinzufügen'), findsAtLeastNWidgets(1));

        // Fill waypoint form
        final formFields = find.byType(TextFormField);
        await tester.enterText(formFields.at(0), 'Test Waypoint 1');
        await tester.enterText(formFields.at(1), 'Test Description');
        await tester.enterText(formFields.at(2), '52.5200');
        await tester.enterText(formFields.at(3), '13.4050');
        await tester.enterText(formFields.at(4), 'Glenfiddich 12');

        // Mock waypoint creation
        final newWaypoint = {
          'waypoint_id': 456,
          'order_index': 1,
          'waypoints': {
            'id': 456,
            'name': 'Test Waypoint 1',
            'description': 'Test Description',
            'latitude': 52.5200,
            'longitude': 13.4050,
            'whisky_info': 'Glenfiddich 12',
          },
        };

        when(
          mockService.addWaypointToRoute(123, any),
        ).thenAnswer((_) async => newWaypoint['waypoints']);

        mockWaypoints.add(newWaypoint);
        when(
          mockService.getRouteWaypoints(123),
        ).thenAnswer((_) async => mockWaypoints);

        // Submit waypoint form
        await tester.tap(find.text('Hinzufügen'));
        await tester.pumpAndSettle();

        // Verify waypoint was added
        verify(mockService.addWaypointToRoute(123, any)).called(1);
        verify(mockService.getRouteWaypoints(123)).called(atLeast(2));

        // Verify waypoint appears in list
        expect(find.text('Test Waypoint 1'), findsOneWidget);
        expect(find.text('Glenfiddich 12'), findsOneWidget);
        expect(find.text('52.5200, 13.4050'), findsOneWidget);
      });

      testWidgets('should handle search and filter functionality', (
        tester,
      ) async {
        // Arrange
        final mockRoutes = [
          {
            'id': 123,
            'name': 'Highland Route',
            'description': 'Highland Description',
            'difficulty': 'easy',
            'distance': 8.5,
            'duration': 180,
            'price': 79.99,
            'is_active': true,
          },
          {
            'id': 124,
            'name': 'Speyside Adventure',
            'description': 'Speyside Description',
            'difficulty': 'moderate',
            'distance': 12.3,
            'duration': 300,
            'price': 89.99,
            'is_active': false,
          },
          {
            'id': 125,
            'name': 'Islay Challenge',
            'description': 'Islay Description',
            'difficulty': 'hard',
            'distance': 15.7,
            'duration': 420,
            'price': 99.99,
            'is_active': true,
          },
        ];

        when(
          mockService.getAllRoutesForAdmin(),
        ).thenAnswer((_) async => mockRoutes);

        await tester.pumpWidget(
          createTestApp(child: const RouteManagementPage()),
        );
        await tester.pumpAndSettle();

        // Verify all routes are shown initially
        expect(find.text('Highland Route'), findsOneWidget);
        expect(find.text('Speyside Adventure'), findsOneWidget);
        expect(find.text('Islay Challenge'), findsOneWidget);

        // Test search functionality
        await tester.enterText(find.byType(TextField), 'Highland');
        await tester.pumpAndSettle();

        // Verify search results
        expect(find.text('Highland Route'), findsOneWidget);
        expect(find.text('Speyside Adventure'), findsNothing);
        expect(find.text('Islay Challenge'), findsNothing);

        // Clear search
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pumpAndSettle();

        // Verify all routes shown again
        expect(find.text('Highland Route'), findsOneWidget);
        expect(find.text('Speyside Adventure'), findsOneWidget);
        expect(find.text('Islay Challenge'), findsOneWidget);

        // Test difficulty filter
        await tester.tap(find.text('Leicht'));
        await tester.pumpAndSettle();

        // Verify only easy routes shown
        expect(find.text('Highland Route'), findsOneWidget);
        expect(find.text('Speyside Adventure'), findsNothing);
        expect(find.text('Islay Challenge'), findsNothing);

        // Test status filter
        await tester.tap(find.text('Alle')); // Reset difficulty filter
        await tester.pumpAndSettle();
        await tester.tap(find.text('Inaktiv'));
        await tester.pumpAndSettle();

        // Verify only inactive routes shown
        expect(find.text('Highland Route'), findsNothing);
        expect(find.text('Speyside Adventure'), findsOneWidget);
        expect(find.text('Islay Challenge'), findsNothing);
      });
    });

    group('Error Handling Integration', () {
      testWidgets('should handle service errors gracefully', (tester) async {
        // Arrange
        when(
          mockService.getAllRoutesForAdmin(),
        ).thenThrow(Exception('Network error'));

        await tester.pumpWidget(
          createTestApp(child: const RouteManagementPage()),
        );
        await tester.pumpAndSettle();

        // Verify error state
        expect(find.text('Network error'), findsOneWidget);
        expect(find.text('Erneut versuchen'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);

        // Test retry functionality
        when(mockService.getAllRoutesForAdmin()).thenAnswer((_) async => []);

        await tester.tap(find.text('Erneut versuchen'));
        await tester.pumpAndSettle();

        // Verify retry worked
        expect(find.text('Network error'), findsNothing);
        expect(find.text('Keine Routen verfügbar'), findsOneWidget);
      });

      testWidgets('should handle form validation errors', (tester) async {
        // Arrange
        when(mockService.getAllRoutesForAdmin()).thenAnswer((_) async => []);

        await tester.pumpWidget(
          createTestApp(child: const RouteManagementPage()),
        );
        await tester.pumpAndSettle();

        // Open create dialog
        await tester.tap(find.text('Erste Route erstellen'));
        await tester.pumpAndSettle();

        // Try to submit empty form
        await tester.tap(find.text('Erstellen'));
        await tester.pumpAndSettle();

        // Verify validation errors
        expect(find.text('Name ist erforderlich'), findsOneWidget);
        expect(find.text('Distanz ist erforderlich'), findsOneWidget);
        expect(find.text('Dauer ist erforderlich'), findsOneWidget);
        expect(find.text('Preis ist erforderlich'), findsOneWidget);

        // Verify service was not called
        verifyNever(mockService.createRoute(any));
      });
    });

    group('Responsive Layout Integration', () {
      testWidgets('should adapt layout for mobile screen', (tester) async {
        // Arrange
        await tester.binding.setSurfaceSize(
          const Size(400, 800),
        ); // Mobile size

        final mockRoute = {
          'id': 123,
          'name': 'Test Route',
          'is_active': true,
          'price': 89.99,
          'distance': 10.5,
          'duration': 240,
        };

        when(
          mockService.getAllRoutesForAdmin(),
        ).thenAnswer((_) async => [mockRoute]);

        await tester.pumpWidget(
          createTestApp(child: const RouteManagementPage()),
        );
        await tester.pumpAndSettle();

        // Verify mobile layout elements
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(GridView), findsNothing);

        // Verify waypoint management is not visible on mobile when no route selected
        expect(find.text('Wegpunkte verwalten'), findsNothing);
      });

      testWidgets('should adapt layout for desktop screen', (tester) async {
        // Arrange
        await tester.binding.setSurfaceSize(
          const Size(1200, 800),
        ); // Desktop size

        final mockRoute = {
          'id': 123,
          'name': 'Test Route',
          'is_active': true,
          'price': 89.99,
          'distance': 10.5,
          'duration': 240,
        };

        when(
          mockService.getAllRoutesForAdmin(),
        ).thenAnswer((_) async => [mockRoute]);

        when(mockService.getRouteWaypoints(123)).thenAnswer((_) async => []);

        await tester.pumpWidget(
          createTestApp(child: const RouteManagementPage()),
        );
        await tester.pumpAndSettle();

        // Verify desktop layout elements
        expect(
          find.byType(AppBar),
          findsNothing,
        ); // No app bar in desktop layout
        expect(find.byType(GridView), findsOneWidget);

        // Select a route to show waypoint panel
        await tester.tap(find.text('Test Route'));
        await tester.pumpAndSettle();

        // Verify waypoint panel is visible on desktop
        expect(find.text('Wegpunkte verwalten'), findsOneWidget);
      });
    });

    group('Performance Integration', () {
      testWidgets('should handle large datasets efficiently', (tester) async {
        // Arrange
        final largeRouteList = List.generate(
          100,
          (index) => {
            'id': index,
            'name': 'Route $index',
            'description': 'Description $index',
            'difficulty': ['easy', 'moderate', 'hard'][index % 3],
            'distance': 8.0 + index,
            'duration': 180 + index * 10,
            'price': 79.99 + index,
            'is_active': index % 2 == 0,
            'created_at': '2024-01-01T10:00:00Z',
          },
        );

        when(
          mockService.getAllRoutesForAdmin(),
        ).thenAnswer((_) async => largeRouteList);

        // Act
        final stopwatch = Stopwatch()..start();
        await tester.pumpWidget(
          createTestApp(child: const RouteManagementPage()),
        );
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(2000),
        ); // Should render within 2 seconds
        expect(find.text('Route 0'), findsOneWidget);
        expect(find.text('Route 99'), findsOneWidget);

        // Test search performance with large dataset
        final searchStopwatch = Stopwatch()..start();
        await tester.enterText(find.byType(TextField), 'Route 5');
        await tester.pumpAndSettle();
        searchStopwatch.stop();

        expect(
          searchStopwatch.elapsedMilliseconds,
          lessThan(500),
        ); // Search should be fast
        expect(find.text('Route 5'), findsOneWidget);
        expect(find.text('Route 50'), findsOneWidget); // Matches substring
      });
    });

    tearDown(() {
      // Reset surface size
      tester.binding.setSurfaceSize(null);
    });
  });
}
