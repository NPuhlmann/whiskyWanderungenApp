import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:whisky_hikes/UI/mobile/home/widgets/card_widget.dart';
import 'package:whisky_hikes/domain/models/hike.dart';

import '../../../test_helpers.dart';

void main() {
  group('HikeCard Widget Tests', () {
    late Hike testHike;
    late MockGoRouter mockRouter;
    bool favoriteToggleCalled = false;
    Hike? toggledHike;

    setUp(() {
      testHike = TestHelpers.createTestHike(
        id: 1,
        name: 'Test Hike',
        description: 'Test Description',
        difficulty: Difficulty.easy,
        thumbnailImageUrl: 'https://example.com/image.jpg',
        isFavorite: false,
      );
      mockRouter = MockGoRouter();
      favoriteToggleCalled = false;
      toggledHike = null;
    });

    testWidgets('should display hike card with correct information', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          HikeCard(
            id: 1,
            hike: testHike,
            isInGeneralList: true,
            onFavoriteToggle: (hike) {
              favoriteToggleCalled = true;
              toggledHike = hike;
            },
          ),
          mockRouter: mockRouter,
        ),
      );

      // Check if hike card displays correct information
      expect(find.text('Test Hike'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget); // Localized difficulty
      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets(
      'should handle favorite toggle when favorite button is pressed',
      (tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestWidget(
            HikeCard(
              id: 1,
              hike: testHike,
              isInGeneralList: true,
              onFavoriteToggle: (hike) {
                favoriteToggleCalled = true;
                toggledHike = hike;
              },
            ),
            mockRouter: mockRouter,
          ),
        );

        // Find and tap the favorite button
        final favoriteButton = find.byIcon(Icons.favorite_border);
        expect(favoriteButton, findsOneWidget);

        await tester.tap(favoriteButton);
        await tester.pumpAndSettle();

        // Verify favorite toggle was called
        expect(favoriteToggleCalled, true);
        expect(toggledHike, equals(testHike));
      },
    );

    testWidgets('should display filled favorite icon when hike is favorite', (
      tester,
    ) async {
      final favoriteHike = testHike.copyWith(isFavorite: true);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          HikeCard(
            id: 1,
            hike: favoriteHike,
            isInGeneralList: true,
            onFavoriteToggle: (hike) {},
          ),
          mockRouter: mockRouter,
        ),
      );

      // Should show filled favorite icon
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets(
      'should navigate to correct route when tapped from general list',
      (tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestWidget(
            HikeCard(
              id: 1,
              hike: testHike,
              isInGeneralList: true,
              onFavoriteToggle: (hike) {},
            ),
            mockRouter: mockRouter,
          ),
        );

        // Tap the card
        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        // Verify navigation was called
        verify(
          mockRouter.go(
            '/hikeDetails',
            extra: argThat(contains('hike'), named: 'extra'),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'should navigate to correct route when tapped from my hikes list',
      (tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestWidget(
            HikeCard(
              id: 1,
              hike: testHike,
              isInGeneralList: false, // From MyHikes
              onFavoriteToggle: (hike) {},
            ),
            mockRouter: mockRouter,
          ),
        );

        // Tap the card
        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        // Verify navigation to MyHikes subroute
        verify(
          mockRouter.go(
            '/myHikes/hikeDetails',
            extra: argThat(contains('hike'), named: 'extra'),
          ),
        ).called(1);
      },
    );

    testWidgets('should display different difficulty levels correctly', (
      tester,
    ) async {
      final difficultHike = testHike.copyWith(difficulty: Difficulty.veryHard);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          HikeCard(
            id: 1,
            hike: difficultHike,
            isInGeneralList: true,
            onFavoriteToggle: (hike) {},
          ),
          mockRouter: mockRouter,
        ),
      );

      // Should show localized very hard difficulty
      expect(find.text('Very Hard'), findsOneWidget);
    });

    testWidgets('should handle missing thumbnail gracefully', (tester) async {
      final hikeWithoutThumbnail = testHike.copyWith(thumbnailImageUrl: null);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          HikeCard(
            id: 1,
            hike: hikeWithoutThumbnail,
            isInGeneralList: true,
            onFavoriteToggle: (hike) {},
          ),
          mockRouter: mockRouter,
        ),
      );

      // Should still build without crashing
      expect(find.byType(HikeCard), findsOneWidget);
    });

    testWidgets('should handle long hike names appropriately', (tester) async {
      final longNameHike = testHike.copyWith(
        name:
            'This is a very long hike name that might cause overflow issues in the UI',
      );

      await tester.pumpWidget(
        TestHelpers.createTestWidget(
          HikeCard(
            id: 1,
            hike: longNameHike,
            isInGeneralList: true,
            onFavoriteToggle: (hike) {},
          ),
          mockRouter: mockRouter,
        ),
      );

      // Should handle long text without overflow
      expect(find.byType(HikeCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
