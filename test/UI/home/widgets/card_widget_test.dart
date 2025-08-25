import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:whisky_hikes/UI/home/widgets/card_widget.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('HikeCard Widget Tests', () {
    late Hike testHike;
    late Function(Hike) mockOnFavoriteToggle;

    setUp(() {
      testHike = Hike(
        id: 1,
        name: 'Test Hike',
        description: 'A beautiful test hike through the mountains',
        difficulty: Difficulty.easy,
        length: 5.5,
        price: 29.99,
        isFavorite: false,
        thumbnailImageUrl: 'https://example.com/image.jpg',
      );
      mockOnFavoriteToggle = (Hike hike) {};
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
          Locale('en', ''),
          Locale('de', ''),
        ],
        home: Scaffold(body: child),
      );
    }

    testWidgets('should build without crashing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          HikeCard(
            id: 0,
            hike: testHike,
            isInGeneralList: true,
            onFavoriteToggle: mockOnFavoriteToggle,
          ),
        ),
      );

      // Assert
      expect(find.byType(HikeCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('should display hike information correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          HikeCard(
            id: 0,
            hike: testHike,
            isInGeneralList: true,
            onFavoriteToggle: mockOnFavoriteToggle,
          ),
        ),
      );

      // Assert
      expect(find.text('Test Hike'), findsOneWidget);
      expect(find.text('A beautiful test hike through the mountains'), findsOneWidget);
      expect(find.text('5.5'), findsOneWidget);
      expect(find.text(' km'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
    });

    testWidgets('should display difficulty strings correctly', (WidgetTester tester) async {
      // Test each difficulty level
      final difficulties = [
        (Difficulty.easy, 'Easy'),
        (Difficulty.mid, 'Medium'),
        (Difficulty.hard, 'Hard'),
        (Difficulty.veryHard, 'Very Hard'),
      ];

      for (final (difficulty, expectedText) in difficulties) {
        final hikeWithDifficulty = testHike.copyWith(difficulty: difficulty);

        await tester.pumpWidget(
          createTestWidget(
            HikeCard(
              id: 0,
              hike: hikeWithDifficulty,
              isInGeneralList: true,
              onFavoriteToggle: mockOnFavoriteToggle,
            ),
          ),
        );

        expect(find.text(expectedText), findsOneWidget);
      }
    });

    testWidgets('should show favorite button when in general list', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          HikeCard(
            id: 0,
            hike: testHike,
            isInGeneralList: true,
            onFavoriteToggle: mockOnFavoriteToggle,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should not show favorite button when not in general list', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          HikeCard(
            id: 0,
            hike: testHike,
            isInGeneralList: false,
            onFavoriteToggle: mockOnFavoriteToggle,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.favorite_border), findsNothing);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('should show filled heart for favorite hike', (WidgetTester tester) async {
      // Arrange
      final favoriteHike = testHike.copyWith(isFavorite: true);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          HikeCard(
            id: 0,
            hike: favoriteHike,
            isInGeneralList: true,
            onFavoriteToggle: mockOnFavoriteToggle,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('should display cached network image when thumbnail URL is provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          HikeCard(
            id: 0,
            hike: testHike,
            isInGeneralList: true,
            onFavoriteToggle: mockOnFavoriteToggle,
          ),
        ),
      );

      // Assert
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('should display asset image when thumbnail URL is null', (WidgetTester tester) async {
      // Arrange
      final hikeWithoutImage = testHike.copyWith(thumbnailImageUrl: null);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          HikeCard(
            id: 0,
            hike: hikeWithoutImage,
            isInGeneralList: true,
            onFavoriteToggle: mockOnFavoriteToggle,
          ),
        ),
      );

      // Assert
      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should call onFavoriteToggle when favorite button is pressed', (WidgetTester tester) async {
      // Arrange
      bool toggleCalled = false;
      Hike? toggledHike;

      void testToggle(Hike hike) {
        toggleCalled = true;
        toggledHike = hike;
      }

      // Act
      await tester.pumpWidget(
        createTestWidget(
          HikeCard(
            id: 0,
            hike: testHike,
            isInGeneralList: true,
            onFavoriteToggle: testToggle,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));

      // Assert
      expect(toggleCalled, isTrue);
      expect(toggledHike, equals(testHike));
    });

    testWidgets('should display correct icons for distance and difficulty', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          HikeCard(
            id: 0,
            hike: testHike,
            isInGeneralList: true,
            onFavoriteToggle: mockOnFavoriteToggle,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.straighten), findsOneWidget);
      expect(find.byIcon(Icons.terrain), findsOneWidget);
    });

    testWidgets('should have correct card styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          HikeCard(
            id: 0,
            hike: testHike,
            isInGeneralList: true,
            onFavoriteToggle: mockOnFavoriteToggle,
          ),
        ),
      );

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(5));
      expect(card.shape, isA<RoundedRectangleBorder>());
      
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(const BorderRadius.vertical(top: Radius.circular(16))));
    });

    testWidgets('should truncate long descriptions correctly', (WidgetTester tester) async {
      // Arrange
      final longDescription = 'This is a very long description that should be truncated when displayed in the card widget because it exceeds the maximum number of lines allowed for the description text field which is set to three lines maximum';
      final hikeWithLongDescription = testHike.copyWith(description: longDescription);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          HikeCard(
            id: 0,
            hike: hikeWithLongDescription,
            isInGeneralList: true,
            onFavoriteToggle: mockOnFavoriteToggle,
          ),
        ),
      );

      // Assert
      final textWidget = tester.widget<Text>(find.text(longDescription));
      expect(textWidget.maxLines, equals(3));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should handle tap gesture correctly', (WidgetTester tester) async {
      // Create a simple router for testing
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(),
          ),
          GoRoute(
            path: '/hikeDetails',
            builder: (context, state) => const Scaffold(body: Text('Details Page')),
          ),
          GoRoute(
            path: '/myHikes/hikeDetails',
            builder: (context, state) => const Scaffold(body: Text('My Hikes Details Page')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('de', ''),
          ],
          builder: (context, child) => Scaffold(
            body: HikeCard(
              id: 0,
              hike: testHike,
              isInGeneralList: true,
              onFavoriteToggle: mockOnFavoriteToggle,
            ),
          ),
        ),
      );

      // Act - Tap the card
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Assert - Should navigate to details page
      expect(find.text('Details Page'), findsOneWidget);
    });

    testWidgets('should handle image loading error gracefully', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          HikeCard(
            id: 0,
            hike: testHike,
            isInGeneralList: true,
            onFavoriteToggle: mockOnFavoriteToggle,
          ),
        ),
      );

      // Find the CachedNetworkImage and get its error widget
      final cachedImageFinder = find.byType(CachedNetworkImage);
      expect(cachedImageFinder, findsOneWidget);

      final CachedNetworkImage cachedImage = tester.widget(cachedImageFinder);
      final errorWidget = cachedImage.errorWidget?.call(
        tester.element(cachedImageFinder),
        'test-url',
        Exception('Test error'),
      );

      // Assert
      expect(errorWidget, isNotNull);
    });
  });
}