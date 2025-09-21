import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/web/admin/route_management/waypoint_management_widget.dart';
import 'package:whisky_hikes/data/providers/route_management_provider.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

@GenerateMocks([RouteManagementProvider])
import 'waypoint_management_widget_test.mocks.dart';

void main() {
  group('WaypointManagementWidget Tests', () {
    late MockRouteManagementProvider mockProvider;

    setUp(() {
      mockProvider = MockRouteManagementProvider();

      // Default mock values
      when(mockProvider.waypoints).thenReturn([]);
      when(mockProvider.selectedRoute).thenReturn(null);
      when(mockProvider.isLoading).thenReturn(false);
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
          child: Scaffold(body: child),
        ),
      );
    }

    group('Initial State', () {
      testWidgets('should show empty state when no route selected', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn(null);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Keine Route ausgewählt'), findsOneWidget);
        expect(find.text('Wählen Sie eine Route aus, um Wegpunkte zu verwalten'), findsOneWidget);
        expect(find.byIcon(Icons.route), findsOneWidget);
      });

      testWidgets('should show empty waypoints state when route selected but no waypoints', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });
        when(mockProvider.waypoints).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Keine Wegpunkte'), findsOneWidget);
        expect(find.text('Fügen Sie Wegpunkte zu dieser Route hinzu'), findsOneWidget);
        expect(find.byIcon(Icons.add_location), findsOneWidget);
      });

      testWidgets('should show loading state when loading', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });
        when(mockProvider.isLoading).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Waypoint Display', () {
      testWidgets('should display waypoints list when waypoints available', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });

        final mockWaypoints = [
          {
            'waypoint_id': 456,
            'order_index': 1,
            'waypoints': {
              'id': 456,
              'name': 'Wegpunkt 1',
              'description': 'Beschreibung 1',
              'latitude': 52.5200,
              'longitude': 13.4050,
              'whisky_info': 'Glenfiddich 12',
            }
          },
          {
            'waypoint_id': 457,
            'order_index': 2,
            'waypoints': {
              'id': 457,
              'name': 'Wegpunkt 2',
              'description': 'Beschreibung 2',
              'latitude': 52.5300,
              'longitude': 13.4150,
              'whisky_info': 'Macallan 15',
            }
          },
        ];

        when(mockProvider.waypoints).thenReturn(mockWaypoints);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Wegpunkt 1'), findsOneWidget);
        expect(find.text('Wegpunkt 2'), findsOneWidget);
        expect(find.text('Glenfiddich 12'), findsOneWidget);
        expect(find.text('Macallan 15'), findsOneWidget);
        expect(find.text('52.5200, 13.4050'), findsOneWidget);
        expect(find.text('52.5300, 13.4150'), findsOneWidget);
      });

      testWidgets('should show waypoint order numbers', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });

        final mockWaypoints = [
          {
            'waypoint_id': 456,
            'order_index': 1,
            'waypoints': {
              'id': 456,
              'name': 'Erster Wegpunkt',
              'latitude': 52.5200,
              'longitude': 13.4050,
            }
          },
          {
            'waypoint_id': 457,
            'order_index': 2,
            'waypoints': {
              'id': 457,
              'name': 'Zweiter Wegpunkt',
              'latitude': 52.5300,
              'longitude': 13.4150,
            }
          },
        ];

        when(mockProvider.waypoints).thenReturn(mockWaypoints);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('should display waypoint action buttons', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });

        final mockWaypoints = [
          {
            'waypoint_id': 456,
            'order_index': 1,
            'waypoints': {
              'id': 456,
              'name': 'Test Wegpunkt',
              'latitude': 52.5200,
              'longitude': 13.4050,
            }
          },
        ];

        when(mockProvider.waypoints).thenReturn(mockWaypoints);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);
        expect(find.byIcon(Icons.drag_handle), findsOneWidget);
      });
    });

    group('Add Waypoint', () {
      testWidgets('should show add waypoint button when route selected', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });
        when(mockProvider.waypoints).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Wegpunkt hinzufügen'), findsOneWidget);
        expect(find.byIcon(Icons.add_location), findsAtLeastNWidgets(1));
      });

      testWidgets('should open add waypoint dialog when button is tapped', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });
        when(mockProvider.waypoints).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Wegpunkt hinzufügen'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Wegpunkt hinzufügen'), findsAtLeastNWidgets(1));
      });

      testWidgets('should have form fields in add waypoint dialog', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });
        when(mockProvider.waypoints).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Wegpunkt hinzufügen'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Name'), findsOneWidget);
        expect(find.text('Beschreibung'), findsOneWidget);
        expect(find.text('Breitengrad'), findsOneWidget);
        expect(find.text('Längengrad'), findsOneWidget);
        expect(find.text('Whisky Information'), findsOneWidget);
        expect(find.byType(TextFormField), findsAtLeastNWidgets(5));
      });

      testWidgets('should call addWaypoint when form is submitted', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });
        when(mockProvider.waypoints).thenReturn([]);
        when(mockProvider.addWaypoint(any, any)).thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Wegpunkt hinzufügen'));
        await tester.pumpAndSettle();

        // Fill form
        await tester.enterText(find.byType(TextFormField).at(0), 'Test Wegpunkt');
        await tester.enterText(find.byType(TextFormField).at(1), 'Test Beschreibung');
        await tester.enterText(find.byType(TextFormField).at(2), '52.5200');
        await tester.enterText(find.byType(TextFormField).at(3), '13.4050');
        await tester.enterText(find.byType(TextFormField).at(4), 'Glenfiddich 12');

        await tester.tap(find.text('Hinzufügen'));
        await tester.pumpAndSettle();

        // Assert
        verify(mockProvider.addWaypoint(123, any)).called(1);
      });
    });

    group('Edit Waypoint', () {
      testWidgets('should open edit dialog when edit button is tapped', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });

        final mockWaypoints = [
          {
            'waypoint_id': 456,
            'order_index': 1,
            'waypoints': {
              'id': 456,
              'name': 'Test Wegpunkt',
              'description': 'Test Beschreibung',
              'latitude': 52.5200,
              'longitude': 13.4050,
              'whisky_info': 'Glenfiddich 12',
            }
          },
        ];

        when(mockProvider.waypoints).thenReturn(mockWaypoints);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Wegpunkt bearbeiten'), findsOneWidget);
        expect(find.text('Test Wegpunkt'), findsAtLeastNWidgets(1)); // Pre-filled form
      });

      testWidgets('should pre-fill form with existing waypoint data', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });

        final mockWaypoints = [
          {
            'waypoint_id': 456,
            'order_index': 1,
            'waypoints': {
              'id': 456,
              'name': 'Existing Waypoint',
              'description': 'Existing Description',
              'latitude': 52.5200,
              'longitude': 13.4050,
              'whisky_info': 'Existing Whisky',
            }
          },
        ];

        when(mockProvider.waypoints).thenReturn(mockWaypoints);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Existing Waypoint'), findsAtLeastNWidgets(1));
        expect(find.text('Existing Description'), findsAtLeastNWidgets(1));
        expect(find.text('52.5200'), findsAtLeastNWidgets(1));
        expect(find.text('13.4050'), findsAtLeastNWidgets(1));
        expect(find.text('Existing Whisky'), findsAtLeastNWidgets(1));
      });
    });

    group('Delete Waypoint', () {
      testWidgets('should show delete confirmation dialog', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });

        final mockWaypoints = [
          {
            'waypoint_id': 456,
            'order_index': 1,
            'waypoints': {
              'id': 456,
              'name': 'Test Wegpunkt',
              'latitude': 52.5200,
              'longitude': 13.4050,
            }
          },
        ];

        when(mockProvider.waypoints).thenReturn(mockWaypoints);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Wegpunkt löschen'), findsOneWidget);
        expect(find.text('Möchten Sie diesen Wegpunkt wirklich löschen?'), findsOneWidget);
        expect(find.text('Abbrechen'), findsOneWidget);
        expect(find.text('Löschen'), findsOneWidget);
      });

      testWidgets('should call removeWaypoint when deletion is confirmed', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });

        final mockWaypoints = [
          {
            'waypoint_id': 456,
            'order_index': 1,
            'waypoints': {
              'id': 456,
              'name': 'Test Wegpunkt',
              'latitude': 52.5200,
              'longitude': 13.4050,
            }
          },
        ];

        when(mockProvider.waypoints).thenReturn(mockWaypoints);
        when(mockProvider.removeWaypoint(123, 456)).thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Löschen'));
        await tester.pumpAndSettle();

        // Assert
        verify(mockProvider.removeWaypoint(123, 456)).called(1);
      });
    });

    group('Drag and Drop Reordering', () {
      testWidgets('should show drag handles for reordering', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });

        final mockWaypoints = [
          {
            'waypoint_id': 456,
            'order_index': 1,
            'waypoints': {
              'id': 456,
              'name': 'Wegpunkt 1',
              'latitude': 52.5200,
              'longitude': 13.4050,
            }
          },
          {
            'waypoint_id': 457,
            'order_index': 2,
            'waypoints': {
              'id': 457,
              'name': 'Wegpunkt 2',
              'latitude': 52.5300,
              'longitude': 13.4150,
            }
          },
        ];

        when(mockProvider.waypoints).thenReturn(mockWaypoints);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
        expect(find.byType(ReorderableListView), findsOneWidget);
      });

      testWidgets('should call reorderWaypoints when items are reordered', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });

        final mockWaypoints = [
          {
            'waypoint_id': 456,
            'order_index': 1,
            'waypoints': {
              'id': 456,
              'name': 'Wegpunkt 1',
              'latitude': 52.5200,
              'longitude': 13.4050,
            }
          },
          {
            'waypoint_id': 457,
            'order_index': 2,
            'waypoints': {
              'id': 457,
              'name': 'Wegpunkt 2',
              'latitude': 52.5300,
              'longitude': 13.4150,
            }
          },
        ];

        when(mockProvider.waypoints).thenReturn(mockWaypoints);
        when(mockProvider.reorderWaypoints(any, any)).thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        final reorderableList = find.byType(ReorderableListView);
        await tester.drag(reorderableList.first, const Offset(0, 100));
        await tester.pumpAndSettle();

        // Assert
        verify(mockProvider.reorderWaypoints(123, any)).called(1);
      });
    });

    group('Map Integration', () {
      testWidgets('should show map view toggle button', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });
        when(mockProvider.waypoints).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.map), findsOneWidget);
        expect(find.text('Kartenansicht'), findsOneWidget);
      });

      testWidgets('should switch to map view when toggle is pressed', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });

        final mockWaypoints = [
          {
            'waypoint_id': 456,
            'order_index': 1,
            'waypoints': {
              'id': 456,
              'name': 'Test Wegpunkt',
              'latitude': 52.5200,
              'longitude': 13.4050,
            }
          },
        ];

        when(mockProvider.waypoints).thenReturn(mockWaypoints);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Kartenansicht'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Listenansicht'), findsOneWidget);
        expect(find.byIcon(Icons.list), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should display error message when present', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });
        when(mockProvider.errorMessage).thenReturn('Failed to load waypoints');

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Failed to load waypoints'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      });

      testWidgets('should show retry option when error occurs', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });
        when(mockProvider.errorMessage).thenReturn('Network error');
        when(mockProvider.selectRoute(any)).thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Erneut versuchen'), findsOneWidget);
      });
    });

    group('Form Validation', () {
      testWidgets('should validate required fields in add waypoint form', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });
        when(mockProvider.waypoints).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Wegpunkt hinzufügen'));
        await tester.pumpAndSettle();

        // Try to submit empty form
        await tester.tap(find.text('Hinzufügen'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Name ist erforderlich'), findsOneWidget);
        expect(find.text('Breitengrad ist erforderlich'), findsOneWidget);
        expect(find.text('Längengrad ist erforderlich'), findsOneWidget);
        verifyNever(mockProvider.addWaypoint(any, any));
      });

      testWidgets('should validate coordinate format', (tester) async {
        // Arrange
        when(mockProvider.selectedRoute).thenReturn({
          'id': 123,
          'name': 'Test Route',
        });
        when(mockProvider.waypoints).thenReturn([]);

        // Act
        await tester.pumpWidget(createTestWidget(const WaypointManagementWidget()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Wegpunkt hinzufügen'));
        await tester.pumpAndSettle();

        // Enter invalid coordinates
        await tester.enterText(find.byType(TextFormField).at(0), 'Test');
        await tester.enterText(find.byType(TextFormField).at(2), 'invalid_lat');
        await tester.enterText(find.byType(TextFormField).at(3), 'invalid_lng');

        await tester.tap(find.text('Hinzufügen'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Ungültiger Breitengrad'), findsOneWidget);
        expect(find.text('Ungültiger Längengrad'), findsOneWidget);
        verifyNever(mockProvider.addWaypoint(any, any));
      });
    });
  });
}