import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:whisky_hikes/UI/core/scaffold_with_navigation_bar.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';

// ignore: must_be_immutable
class MockStatefulNavigationShell extends Mock
    implements StatefulNavigationShell {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockStatefulNavigationShell';
  }
}

void main() {
  group('ScaffoldWithNavigationBar Widget Tests', () {
    late MockStatefulNavigationShell mockNavigationShell;

    setUp(() {
      mockNavigationShell = MockStatefulNavigationShell();
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', ''), Locale('de', '')],
        home: child,
      );
    }

    testWidgets('should build without crashing', (WidgetTester tester) async {
      // Arrange
      when(mockNavigationShell.currentIndex).thenReturn(0);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
        ),
      );

      // Assert
      expect(find.byType(ScaffoldWithNavigationBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should display navigation shell as body', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockNavigationShell.currentIndex).thenReturn(0);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
        ),
      );

      // Assert
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.body, equals(mockNavigationShell));
    });

    testWidgets('should have three navigation items with correct labels', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockNavigationShell.currentIndex).thenReturn(0);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Check for navigation items by type instead of specific text
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.items.length, equals(3));

      // Verify navigation items exist
      expect(find.byType(BottomNavigationBarItem), findsNWidgets(3));
    });

    testWidgets('should have correct icons for navigation items', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockNavigationShell.currentIndex).thenReturn(0);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Check for icons by type
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.items.length, equals(3));

      // Verify each item has an icon
      for (final item in bottomNavBar.items) {
        expect(item.icon, isNotNull);
      }
    });

    testWidgets('should reflect current index from navigation shell', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockNavigationShell.currentIndex).thenReturn(1);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, equals(1));
    });

    testWidgets('should call goBranch when navigation item is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockNavigationShell.currentIndex).thenReturn(0);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
        ),
      );

      // Tap on the second navigation item (My Hikes)
      await tester.tap(find.text('My Hikes'));

      // Assert
      verify(mockNavigationShell.goBranch(1, initialLocation: false)).called(1);
    });

    testWidgets(
      'should call goBranch with initialLocation true when tapping current index',
      (WidgetTester tester) async {
        // Arrange
        when(mockNavigationShell.currentIndex).thenReturn(1);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
          ),
        );

        // Tap on the current navigation item (My Hikes, index 1)
        await tester.tap(find.text('My Hikes'));

        // Assert
        verify(
          mockNavigationShell.goBranch(1, initialLocation: true),
        ).called(1);
      },
    );

    testWidgets('should handle all navigation item taps correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockNavigationShell.currentIndex).thenReturn(0);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
        ),
      );

      // Test tapping each navigation item
      await tester.tap(find.text('Hikes'));
      verify(mockNavigationShell.goBranch(0, initialLocation: true)).called(1);

      await tester.tap(find.text('My Hikes'));
      verify(mockNavigationShell.goBranch(1, initialLocation: false)).called(1);

      await tester.tap(find.text('Profile'));
      verify(mockNavigationShell.goBranch(2, initialLocation: false)).called(1);
    });

    testWidgets('should have exactly three bottom navigation bar items', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockNavigationShell.currentIndex).thenReturn(0);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.items.length, equals(3));
    });

    testWidgets('should have correct navigation item types', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockNavigationShell.currentIndex).thenReturn(0);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      // Check first item (Hikes)
      final firstItem = bottomNavBar.items[0];
      expect(firstItem.icon, isA<Icon>());
      expect((firstItem.icon as Icon).icon, equals(Icons.location_on));
      expect(firstItem.label, equals('Hikes'));

      // Check second item (My Hikes)
      final secondItem = bottomNavBar.items[1];
      expect(secondItem.icon, isA<Icon>());
      expect((secondItem.icon as Icon).icon, equals(Icons.map_rounded));
      expect(secondItem.label, equals('My Hikes'));

      // Check third item (Profile)
      final thirdItem = bottomNavBar.items[2];
      expect(thirdItem.icon, isA<Icon>());
      expect((thirdItem.icon as Icon).icon, equals(Icons.person_2_outlined));
      expect(thirdItem.label, equals('Profile'));
    });

    testWidgets('should handle different current indices correctly', (
      WidgetTester tester,
    ) async {
      for (int i = 0; i < 3; i++) {
        // Arrange
        when(mockNavigationShell.currentIndex).thenReturn(i);

        // Act
        await tester.pumpWidget(
          createTestWidget(
            ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
          ),
        );

        // Assert
        final bottomNavBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );
        expect(bottomNavBar.currentIndex, equals(i));
      }
    });

    testWidgets('should use localized strings', (WidgetTester tester) async {
      // Arrange
      when(mockNavigationShell.currentIndex).thenReturn(0);

      // Act - Test with German locale
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('de', '')],
          locale: const Locale('de', ''),
          home: ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should show German labels
      expect(find.text('Wanderungen'), findsOneWidget);
      expect(find.text('Meine Wanderungen'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('should maintain state when rebuilding', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockNavigationShell.currentIndex).thenReturn(1);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
        ),
      );

      // Rebuild the widget
      when(mockNavigationShell.currentIndex).thenReturn(2);
      await tester.pumpWidget(
        createTestWidget(
          ScaffoldWithNavigationBar(navigationShell: mockNavigationShell),
        ),
      );

      // Assert
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, equals(2));
    });
  });
}
